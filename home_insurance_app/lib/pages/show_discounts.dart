import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homeinsuranceapp/data/offer.dart';
import 'package:homeinsuranceapp/pages/common_widgets.dart';
import 'package:homeinsuranceapp/pages/style/custom_widgets.dart';
import 'package:homeinsuranceapp/data/offer_service.dart';
import 'package:homeinsuranceapp/pages/payment_page.dart';
import 'package:homeinsuranceapp/data/globals.dart' as globals;
import 'package:optional/optional.dart';
import '../data/offer_service.dart';

//Offers selected by the user
Offer selectedOffer;
List<Offer> offers;
bool onlyShow = false;

class DisplayDiscounts extends StatefulWidget {
  @override
  _DisplayDiscountsState createState() => _DisplayDiscountsState();
}

// This class provides overall layout of the page .
class _DisplayDiscountsState extends State<DisplayDiscounts> {
  bool _hasAuthorization;
  bool _hasDevices;
  bool _hasStructures;
  bool _isStructureSelected;
  bool _loading;

  //Offer State should get reinitialised if the user clicks on back button in middle of flow
  Future<bool> _onBackPressed() async {
    Navigator.of(context).pop(true);
    _isStructureSelected = false;
    _hasDevices = false;
    selectedStructure = Optional.empty();
    selectedOffer = null;
  }

  @override
  void initState() {
    super.initState();
    _hasAuthorization = hasAccess();
    _hasDevices = hasDevices();
    _hasStructures = hasStructures();
    _isStructureSelected = isStructureSelected();
    _loading = false;
  }

  @override
  Widget build(BuildContext context) {
    Map data = ModalRoute.of(context).settings.arguments;
    if (data != null && data['onlyShow'] != null) {
      onlyShow = data['onlyShow'];
    } else {
      onlyShow = false;
    }
    double screenheight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: CommonAppBar(),
        body: Container(
          color: Colors.brown[50],
          child: Column(
            children: <Widget>[
              Expanded(
                // To avoid renderflow in small device sizes , expanded widget is used
                flex: 6,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenwidth / 100,
                          vertical: screenheight / 100),
                      child: Text(
                        'Available Offers',
                        style: CustomTextStyle(fontSize: 30.0),
                      ),
                    ),
                    CustomDivider(
                        height: screenheight / 150, width: screenwidth / 50),
                    _loading
                        ? Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: screenwidth / 100,
                                vertical: screenheight / 100),
                            child: Center(
                              child: Text(
                                'Loading...',
                                style: CustomTextStyle(fontSize: 15.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Container(),
                    !onlyShow && _hasAuthorization
                        ? Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: screenwidth / 100,
                                vertical: screenheight / 100),
                            child: Center(
                              child: Text(
                                'Select Offer',
                                style: CustomTextStyle(fontSize: 15.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Container(),
                    !onlyShow && !_hasAuthorization
                        ? Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: screenwidth / 50,
                                vertical: screenheight / 50),
                            child: Center(
                              child: Text(
                                  'Link devices and then pick a structure to avail offer',
                                  style: CustomTextStyle(fontSize: 15.0)),
                            ),
                          )
                        : Container(),
                    !onlyShow && _hasAuthorization && !_hasDevices
                        ? Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: screenwidth / 100,
                                vertical: screenheight / 100),
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.cached,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      _loading = true;
                                    });
                                    await getDevices();
                                    _loading = false;
                                    offers = sortOffers(offers);
                                    setState(() {
                                      _hasAuthorization = hasAccess();
                                      _hasDevices = hasDevices();
                                      _hasStructures = hasStructures();
                                      _isStructureSelected =
                                          isStructureSelected();
                                    });
                                  },
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'An error occurred while fetching devices. Retry.',
                                    style: CustomTextStyle(fontSize: 15.0),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(height: 0),
                    !onlyShow &&
                            _hasAuthorization &&
                            (!_hasStructures || !_isStructureSelected)
                        ? Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: screenwidth / 100,
                                vertical: screenheight / 100),
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.cached,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    selectedStructure =
                                        await selectStructure(context);
                                    offers = sortOffers(offers);
                                    setState(() {
                                      _hasAuthorization = hasAccess();
                                      _hasDevices = hasDevices();
                                      _hasStructures = hasStructures();
                                      _isStructureSelected =
                                          isStructureSelected();
                                    });
                                  },
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Structure has not been selected . Select the structure to avail discounts ',
                                    style: CustomTextStyle(fontSize: 15.0),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(height: 0),
                    AllDiscounts(),
                    SizedBox(height: screenheight / 30),
                  ],
                ),
              ),
              onlyShow
                  ? Container()
                  : Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              _hasAuthorization
                                  ? Expanded(
                                      flex: 1,
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: FloatingActionButton.extended(
                                          key: Key("Pick Structure"),
                                          heroTag: 'home',
                                          icon: Icon(Icons.home),
                                          label: Text(
                                            'Pick Structure',
                                            style: CustomTextStyle(
                                                fontWeight: FontWeight.w900),
                                          ),
                                          onPressed: () async {
                                            //    Get offers which the user is eligible to get after launching resource picker
                                            selectedStructure =
                                                await selectStructure(context);
                                            offers = sortOffers(offers);
                                            setState(() {
                                              _hasAuthorization = hasAccess();
                                              _hasDevices = hasDevices();
                                              _hasStructures = hasStructures();
                                              _isStructureSelected =
                                                  isStructureSelected();
                                            });
                                          },
                                          backgroundColor:
                                              Colors.lightBlueAccent,
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      flex: 1,
                                      child: Align(
                                        alignment: Alignment.bottomLeft,
                                        child: FloatingActionButton.extended(
                                          key: Key('Link Devices'),
                                          heroTag: 'Discounts',
                                          icon: Icon(Icons.money_off),
                                          label: Text(
                                            'Link Devices',
                                            style: CustomTextStyle(
                                                fontWeight: FontWeight.w900),
                                          ),
                                          onPressed: () async {
                                            //    Get offers which the user is eligible to get after launching resource picker
                                            setState(() {
                                              _loading = true;
                                            });
                                            await linkDevices();
                                            setState(() {
                                              _loading = false;
                                            });
                                            selectedStructure =
                                                await selectStructure(context);
                                            offers = sortOffers(offers);
                                            setState(() {
                                              _hasAuthorization = hasAccess();
                                              _hasDevices = hasDevices();
                                              _hasStructures = hasStructures();
                                              _isStructureSelected =
                                                  isStructureSelected();
                                            });
                                          },
                                          backgroundColor:
                                              Colors.lightBlueAccent,
                                        ),
                                      ),
                                    ),
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: FloatingActionButton.extended(
                                    key: Key('Go to Payment'),
                                    heroTag: 'Payment',
                                    icon: Icon(Icons.arrow_forward),
                                    label: Text(
                                      'Go to Payment',
                                      style: CustomTextStyle(
                                          fontWeight: FontWeight.w900),
                                    ),
                                    onPressed: () {
                                      //Store structure id  since selectedStructure needs to get reinitialised before navigating to payment page
                                      String structureId = "";
                                      if (selectedStructure !=
                                          Optional.empty()) {
                                        structureId =
                                            (selectedStructure.value)['id'];
                                      }
                                      // Clear the initial state and before going for payment
                                      _isStructureSelected = false;
                                      _hasDevices = false;
                                      selectedStructure = Optional.empty();

                                      //pops the current page
                                      Navigator.of(context).pop();
                                      //Pops the previous page in the stack which is choose_policy page.
                                      Navigator.pop(context);
                                      //For now all these arguments are  send to the home page
                                      Navigator.pushNamed(context, Payment.id,
                                          arguments: {
                                            'selectedOffer': selectedOffer,
                                            'selectedPolicy':
                                                data['selectedPolicy'],
                                            'userAddress': data['userAddress'],
                                            'structureId': structureId,
                                          });
                                    },
                                    backgroundColor: Colors.lightBlueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
              SizedBox(height: screenheight / 80),
            ],
          ),
        ),
      ),
    );
  }
}

// This class provides overall layout of the page .
class AllDiscounts extends StatefulWidget {
  @override
  _AllDiscountsState createState() => _AllDiscountsState();
}

class _AllDiscountsState extends State<AllDiscounts> {
  bool _loadingOffers;

  void initState() {
    super.initState();
    offers = [];
    _loadingOffers = true;
    selectedOffer = null;

    globals.offerDao.getOffers().then((value) {
      setState(() {
        offers = sortOffers(value);
      });
      _loadingOffers = false;
    });
  }

  Widget build(BuildContext context) {
    double screenheight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;

    return Expanded(
      child: ListView.builder(
          itemCount: offers.length,
          itemBuilder: (context, index) {
            return Padding(
              key: Key('Offer $index'),
              padding: EdgeInsets.symmetric(
                  vertical: screenheight / 150, horizontal: screenwidth / 20),
              child: Column(
                children: <Widget>[
                  Container(
                    color: onlyShow
                        ? Colors.brown[100]
                        : (selectedOffer == offers[index]
                            ? Colors.blue[200]
                            : canPickOffer(offers[index])
                                ? Colors.brown[100]
                                : Colors.white),
                    child: ListTile(
                      enabled: onlyShow ? true : canPickOffer(offers[index]),
                      selected: (selectedOffer == offers[index]),
                      onTap: () {
                        setState(() {
                          if (onlyShow) return;
                          if (selectedOffer == offers[index]) {
                            selectedOffer = null;
                          } else {
                            selectedOffer = offers[index];
                          }
                        });
                      },
                      title: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                                child: Text(
                              '${offers[index]}',
                              textAlign: TextAlign.left,
                              style: CustomTextStyle(
                                  color: onlyShow || canPickOffer(offers[index])
                                      ? Colors.black
                                      : Colors.grey),
                            )),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                                child: Text(
                              '${offers[index].discount} %',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: onlyShow || canPickOffer(offers[index])
                                      ? Colors.black
                                      : Colors.grey),
                            )),
                          )
                        ],
                      ),
                    ),
                  ),
                  _loadingOffers
                      ? Container(
                          child: Text(
                            'Loading Offers ...',
                            style: CustomTextStyle(),
                          ),
                        )
                      : Container(),
                ],
              ),
            );
          }),
    );
  }
}
