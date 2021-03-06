import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_refresh/flutter_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:repair_server/http_helper/HttpUtils.dart';
import 'package:repair_server/http_helper/api_request.dart';
import 'package:repair_server/order/bottom_bar_helper.dart';
import 'package:repair_server/order/order.dart';
import 'package:repair_server/order/order_detail_bean/orders.dart';
import 'package:repair_server/order/order_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:repair_server/order/order_details.dart';
import 'package:repair_server/http_helper/url_manager.dart';

class OrderMissed extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OrderMissedState();
  }
}

class OrderMissedState extends State<OrderMissed>
    with AutomaticKeepAliveClientMixin {
  int nowPage = 1;
  int limit = 5;
  int total = 0;
  String url = "";
  List<Orders> mo = [];
  var getOrder;

  @override
  void initState() {
    getOrder = getYetReceiveOrder(nowPage, limit);
    super.initState();
  }

  //未接单订单列表
  Future<void> getYetReceiveOrder(int nowPage, int limit) async {
   ApiRequest().getOrderListForDiffType(context, 0,nowPage, limit, "one").then((page){
     if(page!=null){
       setState(() {
         if(page.orders!=null){
           mo.addAll(page.orders);
         }
         total = page.total;
       });
       print(total);
     }
   });

  }

  //下拉刷新
  Future<Null> onHeaderRefresh() {
    return new Future.delayed(new Duration(seconds: 2), () {
      setState(() {
        nowPage = 1;
        mo.clear();
        getYetReceiveOrder(nowPage, limit);
      });
    });
  }

  //上拉加载更多
  Future<Null> onFooterRefresh() {
    return new Future.delayed(new Duration(seconds: 2), () {
      setState(() {
        if (mo.length >= total) {
          Fluttertoast.showToast(msg: "没有更多的订单了");
        } else {
          nowPage += 1;
          getYetReceiveOrder(nowPage, limit);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: FutureBuilder(
            builder: buildPersonalLine,
            future: getOrder));
  }

  Widget buildPersonalLine(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Center(child: Text('还没有开始网络请求'));
      case ConnectionState.active:
        return Text('ConnectionState.active');
      case ConnectionState.waiting:
        return Center(
          child: CircularProgressIndicator(),
        );
      case ConnectionState.done:
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        return Refresh(
            onFooterRefresh: onFooterRefresh,
            onHeaderRefresh: onHeaderRefresh,
            child: ListView.builder(
                itemCount: mo.length==0?1:mo.length,
                itemBuilder: (context, index) {
                  if(mo==null||mo.length==0){
                    return Center(child:Text("暂无相关数据～"));
                  }
                  var missedOrder = mo[index];
                  return Padding(
                      padding: EdgeInsets.fromLTRB(10, 15, 10, 5),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              onTap: () => Navigator.push(context,
                                      new MaterialPageRoute(
                                          builder: (BuildContext context) {
                                    return new OrderDetails(orderId: missedOrder.id,);
                                  })),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                      padding:
                                          EdgeInsets.only(top: 5, bottom: 5),
                                      child: Text(
                                        "订单编号：" + missedOrder.orderNumber,
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      )),
                                  Divider(
                                    height: 2,
                                    color: Colors.grey,
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            missedOrder.contactsName,
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 30),
                                          ),
                                          Text(missedOrder.contactsPhone,
                                              style: TextStyle(
                                                  color: Colors.black))
                                        ],
                                      )),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: 5, bottom: 10),
                                    child: Text(
                                      missedOrder.contactsAddress,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  Text(
                                    "#" + missedOrder.type,
                                    style: TextStyle(color: Colors.lightBlue),
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.only(top: 5, bottom: 5),
                                      child: Text(missedOrder.createTime,
                                          style:
                                              TextStyle(color: Colors.grey))),
                                  Divider(
                                    height: 2,
                                    color: Colors.grey,
                                  ),
                                  BottomBarHelper().buildCaptureOrderBtn(context, missedOrder.id),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ));
                }));
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
