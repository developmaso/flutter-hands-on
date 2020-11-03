import 'package:flutter/material.dart';
import 'package:flutter_hands_on/models/product.dart';
import 'package:flutter_hands_on/pages/product_detail.dart';

// StatelessWidgetを継承
class ProductCard extends StatelessWidget {
  final Product product;

  // コンストラクタでProductを受け取り、フィールドに格納
  // {}はoptional named parameterと呼ばれるもので、this.productはフィールドにセットするためのシンタックスシュガーです
  ProductCard({this.product});

  @override
  Widget build(BuildContext context) {
    // ContainerをGestureDetectorでラップする
    return GestureDetector(
      // onTapは、childウィジェットがタップされたら発火する
      // Navigator.of(context).pushNamedで遷移を実行する
      // 第一引数はルーティング名、argumentsはoptionalでパラメータを渡せる
      // ProductDetailで書いた通り、遷移先のウィジェットでは、
      // ModalRoute.of(context).settings.arguments でこの引数が取得できる
      onTap: () async {
        // print("tapped");
        Navigator.of(context)
            .pushNamed(ProductDetail.routeName, arguments: this.product);
      },
      // Container自体は変更不要
      child: Container(
        margin: EdgeInsets.all(16),
        // Columnはウィジェットを縦に積むことができるウィジェット
        child: Column(
          // childrenにはList<Widget>を渡す
          // 上から表示したい順にウィジェットを配置する
          children: <Widget>[
            Image.network(product.sampleImageUrl),
            // SizedBoxはウィジェットのサイズを固定するためのウィジェット
            // heightやwidthを指定すると、childのウィジェットのサイズがその通りになる便利なウィジェット
            SizedBox(
              height: 40,
              // Product.titleは商品名を表す
              child: Text(product.title),
            ),
            // Product.priceにはその商品の金額が格納されている
            Text("${product.price.toString()}円"),
          ],
        ),
      ),
    );
  }
}
