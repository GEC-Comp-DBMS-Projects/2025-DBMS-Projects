import 'package:ecommerce_admin_app/models/products_model.dart';
import 'package:flutter/material.dart';

class ViewProduct extends StatefulWidget {
  const ViewProduct({super.key});

  @override
  State<ViewProduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as ProductsModel;
    return Scaffold(
      
      appBar: AppBar(title: Text("View Product"),),
      body: Column(
        children: [

          //ui for view products page (not done yet)
          Image.network(arguments.image),
          Text(arguments.name,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          Text("Category: ${arguments.category}"),
          Text("Description: ${arguments.description}"),
          //Text("Old Price: \$${arguments.old_price}"),
          Text("New Price: \$${arguments.new_price}",style: TextStyle(color: Colors.red,fontSize: 18,fontWeight: FontWeight.bold),),
          Text("Available Quantity: ${arguments.maxQuantity}"),
        ],
      ),
      bottomNavigationBar: Row(children: [
        SizedBox(
  height: 60,width: MediaQuery.of(context).size.width*.5,
  // child: ElevatedButton(
  //                   onPressed: () {},
  //                   child: Text("Add to Cart"),
  //                   style: ElevatedButton.styleFrom(
  //                       backgroundColor: Theme.of(context).primaryColor,
  //                       foregroundColor: Colors.white,
  //                       shape: RoundedRectangleBorder()),
  //                 ),
),
SizedBox(
  height: 60,width: MediaQuery.of(context).size.width*.5,
  // child: ElevatedButton(
  //                   onPressed: () {},
  //                   child: Text("Buy Now"),
  //                   style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.white,
  //                       foregroundColor:  Theme.of(context).primaryColor,
  //                       shape: RoundedRectangleBorder()),
  //                 ),
),
      ],),
    );
  }
}