import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homeinsuranceapp/data/offer.dart';
import 'package:homeinsuranceapp/data/policy.dart';
import 'package:homeinsuranceapp/data/user_home_details.dart';

class Purchase {
  Policy policy;
  Offer offer;
  String structureId;
  Timestamp dateOfPurchase;
  UserAddress address;
  double discountedCost;

  //TODO - Handle  the case when Offer is NULL .
  Purchase(this.policy, this.offer, this.structureId, this.dateOfPurchase,
      this.address) {
    //Calculate discounted cost if offer is availed
    if (this.offer != null) {
      this.discountedCost = policy.cost * (1 - 0.01 * offer.discount);
    }
  }

  @override
  String toString() {
    return '{Policy: $policy\nOffer: $offer\nDate: $dateOfPurchase\nstructureId: $structureId\naddress: $address\nDiscounted cost$discountedCost}';
  }
}
