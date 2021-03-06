import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:repair_server/http_helper/HttpUtils.dart';
import 'package:repair_server/http_helper/api_request.dart';
import 'package:repair_server/model/bottom_button.dart';
import 'package:repair_server/order/chooseMaintainer.dart';
import 'package:repair_server/order/order_detail_bean/orders.dart';
import 'package:repair_server/order/order_detail_widgets/bottom_bar_widget.dart';
import 'package:repair_server/order/order_detail_widgets/maintainer_info_widget.dart';
import 'package:repair_server/order/order_detail_widgets/order_description_widget.dart';
import 'package:repair_server/order/order_detail_widgets/order_detail_feedback_widget.dart';
import 'package:repair_server/order/order_detail_widgets/quote_detail_widget.dart';
import 'package:repair_server/order/order_detail_widgets/quoter_info_widget.dart';
import 'package:repair_server/order/order_detail_widgets/user_info_widget.dart';
import 'package:repair_server/order/order_self.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order.dart';
import 'package:repair_server/http_helper/url_manager.dart';
import 'video_player_screen.dart';
import 'package:repair_server/http_helper/url_manager.dart';

class OrderDetails extends StatefulWidget {
  String orderId;
  OrderDetails({this.orderId});

  @override
  State<StatefulWidget> createState() {
    return OrderDetailsState();
  }
}

class OrderDetailsState extends State<OrderDetails> {
  Orders orderDetail;
  Future<Orders> _getOrderDetail;
  String type;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ApiRequest().getType().then((value){
      type = value;
    });
    _getOrderDetail= ApiRequest().getOrderDetailById(context, widget.orderId)/*.then((orders){
      setState(() {
        orderDetail = orders;
      });
    })*/;

  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text("订单详情"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context)),
        ),
        body: Container(
          color: Colors.grey[300],
          child: FutureBuilder<Orders>(
              future: _getOrderDetail,
              builder: _buildDetails),
        ),
        bottomNavigationBar: BottomBarWidget(orders:orderDetail,userType:type ,)
    );
  }


  buildDivider() => new Container(
    height: 15,
    color: Colors.grey[300],
  );


  Widget _buildDetails(BuildContext context, AsyncSnapshot<Orders> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('还没有开始网络请求');
      case ConnectionState.active:
        return Text('ConnectionState.active');
      case ConnectionState.waiting:
        return Center(
          child: CircularProgressIndicator(),
        );
      case ConnectionState.done:
        if (snapshot.hasError){
          return Text('Error: ${snapshot.error}');
        }
        orderDetail = snapshot.data;
        return SingleChildScrollView(
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              OrderDescriptionWidget(orders:snapshot.data), //120
              //buildDivider(), //15
              UserInfoWidget(orders:snapshot.data), //75
              //buildDivider(), //15
              QuoterInfoWidget(orders:snapshot.data), //86
              //buildDivider(),
              QuoteDetailWidget(orders:snapshot.data),//15
              //buildDivider(),
              MaintainerInfoWidget(orders:snapshot.data),
              //buildDivider(),
              OrderDetailFeedbackWidget(orders:snapshot.data),
            ],
          ),
        );
      default:
        Fluttertoast.showToast(msg: "请检查网络连接状态！");
        return Container();
    }
  }
}

