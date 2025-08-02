import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/shop_controller.dart';

class ShopTemplate extends GetView<ShopController> {
  const ShopTemplate({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ShopTemplate'), centerTitle: true),
      body: const Center(
        child: Text('ShopTemplate is working', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
