import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hands_on/components/product_card.dart';
import 'package:flutter_hands_on/pages/product_detail.dart';
import 'package:flutter_hands_on/stores/product_list_store.dart';
import 'package:provider/provider.dart';

// main()はFlutterアプリケーションのエントリポイントです
// main()の中で、runAppにルートとなるウィジェットを格納して呼ぶ必要があります
void main() async {
  await DotEnv().load('.env');
  runApp(MultiProvider(
    // MultiProviderは複数のChangeNotifierProviderを格納できるProviderのこと
    // providersにList<ChangeNotifierProvider>を指定する
    providers: [
      // ChangeNotifierProviderはcreateにデリゲートを取り、この中でChangeNotifierを初期化して返す
      ChangeNotifierProvider(
        create: (context) => ProductListStore(),
      )
    ],
    // childにはもともと表示に使っていたウィジェットを配置する
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Provider.of<T>メソッドでstoreへの参照を取得する
    // Tには、取得したいChangeNotifierのクラスタイプを指定する、今回はProductListStore
    // 引数のcontextは必須、listen: falseはオプショナル引数
    // listenは、「ChangeNotifierのnotifyListeners()が呼ばれたらウィジェットをリビルドするか」のフラグ
    // 今回はリビルドされたくないのでfalse
    final store = Provider.of<ProductListStore>(context, listen: false);
    if (store.products.isEmpty && store.isFetching == false) {
      // 表示すべき商品が空っぽで、かつ取得中でなければStoreに商品を読み込んでもらう
      // buildメソッドはウィジェットがリビルドされるたびに呼ばれるため、制御しないと大量のリクエストが飛ぶこともあるので注意
      store.fetchNextProducts();
    }
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      // MaterialAppのroutesに、遷移したいウィジェットの情報を格納する
      // { ルーティング名: (context) => 表示したいウィジェット, }という形式で記述する
      // {}はMapを表す、ここでは Map<String, Widget Function(BuildContext)>のこと
      routes: {
        ProductDetail.routeName: (context) => ProductDetail(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SUZURI"),
      ),
      // body: Center(
      //   child: Text("Hello, SUZURI!"),
      // ),
      // body を別メソッドへ切り出し
      body: _productsList(context),
    );
  }

  // Widgetを返すメソッド
  // 引数はBuildContextで、呼び出し側のbuildで持っているものを渡す
  Widget _productsList(BuildContext context) {
    // storeの参照を取得
    // ここではStoreに変更があったらウィジェットに反映したいのでlisten: falseは指定しない
    final store = Provider.of<ProductListStore>(context);
    final products = store.products;
    // Storeから取得できた商品の数を見て、表示すべきウィジェットを変える
    // 具体的には、0件→空っぽのリスト、1件以上→実際の商品リスト
    if (products.isEmpty) {
      return Container(
        // GridViewはウィジェットをグリッドで表示してくれるウィジェット
        // iOS UIKitで言うところの UICollectionView
        // GridView.builderというfactory(カスタムコンストラクタ)で初期化する
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            // グリッド横方向のウィジェット数
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            // グリッド表示するウィジェットの縦横比
            childAspectRatio: 0.7,
          ),
          // グリッドに表示したいウィジェットの数
          itemCount: 6,
          // itemBuilderはGridViewのインデックス毎に表示したいウィジェットを返すデリゲート
          // context, indexを引数にとり、ウィジェットを返す関数を指定してやる
          // itemContの回数だけ呼ばれる、この例では6回
          itemBuilder: (context, index) {
            return Container(
              // とりあえずグレーのコンテナを表示してみる
              color: Colors.grey,
              margin: EdgeInsets.all(16),
            );
          },
        ),
      );
    } else {
      // return Center(child: Text("products"));
      return Container(
        // EmptyProductListと同じく、GridView.builderでグリッドビューのウィジェットを表示する
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          // storeから取得できたproductsの数を使う
          itemCount: products.length,
          itemBuilder: (context, index) {
            // itemBuilderで直接Imageウィジェットを返すのではなく、ProductCardウィジェットを返す
            return ProductCard(product: products[index]);
          },
        ),
      );
    }
  }
}
