import 'dart:typed_data';

import 'package:ecommerce_admin_app/controllers/cloudinary_service.dart';
import 'package:ecommerce_admin_app/controllers/db_service.dart';
import 'package:ecommerce_admin_app/models/products_model.dart';
import 'package:ecommerce_admin_app/providers/admin_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ModifyProduct extends StatefulWidget {
  const ModifyProduct({super.key});

  @override
  State<ModifyProduct> createState() => _ModifyProductState();
}

class _ModifyProductState extends State<ModifyProduct> {
  final formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();


  
  late String productId = "";
  
  TextEditingController nameController = TextEditingController();
  TextEditingController oldPriceController = TextEditingController();
  TextEditingController newPriceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController imageController = TextEditingController();
 
  XFile? pickedFile; // for mobile
  Uint8List? webImage; // for web

    // pick image and upload to cloudinary
  Future<void> _pickImageAndCloudinaryUpload() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        // web gives Uint8List
        webImage = await image.readAsBytes();
        pickedFile = image;
        String? res = await uploadToCloudinary(null, webImage); // send webImage
        if (res != null) {
          setState(() {
            imageController.text = res;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Image uploaded successfully")),
          );
        }
      } else {
        // mobile
        pickedFile = image;
        String? res = await uploadToCloudinary(pickedFile, null);
        if (res != null) {
          setState(() {
            imageController.text = res;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Image uploaded successfully")),
          );
        }
      }
    }
  }


//set data from arguments
setData(ProductsModel data) {
    productId = data.id;
    nameController.text = data.name;
    oldPriceController.text = data.old_price.toString();
    newPriceController.text = data.new_price.toString();
    quantityController.text = data.maxQuantity.toString();
    categoryController.text = data.category;
    descController.text = data.description;
    imageController.text = data.image;
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {

    final arguments = ModalRoute.of(context)!.settings.arguments;
    if(arguments!=null && arguments is ProductsModel){
      setData(arguments);
      
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(productId.isNotEmpty?"update product":"add product "),),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Column(children: [

                      TextFormField(
                        controller: nameController,
                        validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                        decoration: InputDecoration(
                            hintText: "Product Name",
                            label: Text("Product Name"),
                            fillColor: Colors.deepPurple.shade50,
                            filled: true),
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      TextFormField(
                        controller: oldPriceController,
                        validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                        decoration: InputDecoration(
                          hintText: "Original Price",
                          label: Text("Original Price"),
                          fillColor: Colors.deepPurple.shade50,
                          filled: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      TextFormField(
                        controller: newPriceController,
                        validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                        decoration: InputDecoration(
                          hintText: "Sell Price",
                          label: Text("Sell Price"),
                          fillColor: Colors.deepPurple.shade50,
                          filled: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      TextFormField(
                        controller: quantityController,
                        validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                        decoration: InputDecoration(
                            hintText: "Quantity Left",
                            label: Text("Quantity Left"),
                            fillColor: Colors.deepPurple.shade50,
                            filled: true),
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      TextFormField(
                        controller: categoryController,
                        validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                        decoration: InputDecoration(
                            hintText: "category",
                            label: Text("category"),
                            fillColor: Colors.deepPurple.shade50,
                            filled: true),
                        onTap:(){
                          showDialog(context: context, builder: (context)=>
                          AlertDialog(
                            title: Text("Select Category"),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  Consumer<AdminProvider>(
                                      builder: (context, value, child) =>
                                          SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: value.categories
                                                  .map((e) => TextButton(
                                                      onPressed: () {
                                                        categoryController
                                                            .text = e["name"];
                                                        setState(() {});
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(e["name"])))
                                                  .toList(),
                                            ),
                                          ))
                                ],


                            ),
                          ));
                        } ,

                      ),



                      
                      SizedBox(
                        height: 10,
                      ),

                      TextFormField(
                        controller: imageController,
                        validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                        decoration: InputDecoration(
                            hintText: "image",
                            label: Text("image"),
                            fillColor: Colors.deepPurple.shade50,
                            filled: true),
                      ),

                      
                      SizedBox(
                        height: 10,
                      ),

                      TextFormField(
                        controller: descController,
                        validator: (v) => v!.isEmpty ? "This cant be empty." : null,
                        maxLines: 3,
                        decoration: InputDecoration(
                            hintText: "Description",
                            label: Text("Description"),
                            fillColor: Colors.deepPurple.shade50,
                            filled: true),
                      ),


                      SizedBox(
                        height: 10,
                      ),


                    if (webImage != null)
                      Image.memory(webImage!, height: 150, fit: BoxFit.contain)
                    else if (pickedFile != null && !kIsWeb)
                      Image.network(pickedFile!.path, height: 150, fit: BoxFit.contain)
                    else if (imageController.text.isNotEmpty)
                      Image.network(imageController.text,
                          height: 150, fit: BoxFit.contain),

                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _pickImageAndCloudinaryUpload,
                      child: const Text("Pick Image"),
                    ),

                    // Image link field
                    TextFormField(
                      controller: imageController,
                      validator: (v) => v!.isEmpty ? "This can't be empty." : null,
                      decoration: const InputDecoration(
                        hintText: "Image Link",
                        label: Text("Image Link"),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(onPressed: (){
                        if(formKey.currentState!.validate()){

                           Map<String, dynamic> data = {
                              "name": nameController.text,
                              "old_price": int.parse(oldPriceController.text),
                              "new_price": int.parse(newPriceController.text),
                              "quantity": int.parse(quantityController.text),
                              "category": categoryController.text,
                              "desc": descController.text,
                              "image": imageController.text
                            };

                            if (productId.isNotEmpty) {
                              DbService()
                                  .updateProduct(docId: productId, data: data);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Product Updated")));
                            } else {
                              DbService().createProduct(data: data);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Product Added")));
                            }

                        }
                      }, child: Text(productId.isNotEmpty
                            ? "Update Product"
                            : "Add Product"))),




            
          
          ],),
        ),
      ),
    ),
    
    
    );
  }
}