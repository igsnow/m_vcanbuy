import 'dart:async';
import 'dart:convert';

import 'package:base_library/base_library.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluintl/fluintl.dart';
import 'package:flukit/flukit.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:m_vcanbuy/common/common.dart';
import 'package:m_vcanbuy/models/models.dart';
import 'package:m_vcanbuy/res/strings.dart';
import 'package:m_vcanbuy/route/routes.dart';
import 'package:m_vcanbuy/utils/http_utils.dart';
import 'package:m_vcanbuy/utils/navigator_util.dart';
import 'package:m_vcanbuy/utils/utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../application.dart';

class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SplashPageState();
  }
}

class SplashPageState extends State<SplashPage> {
  List<String> _guideList = [
    'images/guide1.png',
    'images/guide2.png',
    'images/guide3.png',
    'images/guide4.png'
  ];

  List<Widget> _bannerList = new List();

  Timer _timer;

  int _status = 0;
  int _count = 3;

  SplashModel _splashModel;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  void _initAsync() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 获取上次存储的闪屏页面
    String jsonStr = prefs.getString(Constant.key_splash_model);
    if (ObjectUtil.isNotEmpty(jsonStr)) {
      Map<String, dynamic> splash = json.decode(jsonStr);
      _splashModel = SplashModel.fromJson(splash);
    }

    HttpUtils httpUtils = new HttpUtils();
    // 获取闪屏的广告数据
    httpUtils.getSplash().then((model) {
      if (ObjectUtil.isNotEmpty(model.imgUrl)) {
        if (_splashModel == null || (_splashModel.imgUrl != model.imgUrl)) {
          prefs.setString(Constant.key_splash_model, model.toString());
          setState(() {
            _splashModel = model;
          });
        }
      } else {
        prefs.setString(Constant.key_splash_model, null);
      }
    });

    bool isGuide = prefs.getBool(Constant.key_guide) ?? true;
    // 是否已经加载过引导图
    if (isGuide) {
      _initGuideBanner();
    } else {
      _initSplash();
    }
  }

  _initGuideBanner() {
    setState(() {
      _status = 2;
    });
    for (int i = 0, length = _guideList.length; i < length; i++) {
      if (i == length - 1) {
        _bannerList.add(new Stack(
          children: <Widget>[
            new Image.asset(
              _guideList[i],
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
            ),
            new Align(
              alignment: Alignment.bottomCenter,
              child: new Container(
                margin: EdgeInsets.only(bottom: 160.0),
                child: new InkWell(
                  onTap: () {
                    _goMain();
                  },
                  child: new CircleAvatar(
                    radius: 48.0,
                    backgroundColor: Colors.indigoAccent,
                    child: new Padding(
                      padding: EdgeInsets.all(2.0),
                      child: new Text(
                        '立即体验',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
      } else {
        // print(_guideList[i]);
        _bannerList.add(new Image.asset(
          _guideList[i],
          fit: BoxFit.fill,
          width: double.infinity,
          height: double.infinity,
        ));
      }
    }
  }

  _initSplash() {
    if (_splashModel == null) {
      _goMain();
      return;
    }
    setState(() {
      _status = 1;
    });

    // 倒计时
    _timer = Timer.periodic(new Duration(seconds: 1), (timer) {
      setState(() {
        if (_count <= 1) {
          _timer.cancel();
          _timer = null;
          _goMain();
        } else {
          _count = _count - 1;
        }
      });
    });
  }

  // 跳转主页
  void _goMain() {
    Application.router.navigateTo(
      context,
      Routes.home,
      replace: true,
      transition: TransitionType.fadeIn,
    );
  }

  // 构建闪屏背景
  Widget _buildSplashBg() {
    return new Image.asset(
      'images/splash_bg.png',
      width: double.infinity,
      fit: BoxFit.fill,
      height: double.infinity,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      child: new Stack(
        children: <Widget>[
          new Offstage(
            offstage: !(_status == 0),
            child: _buildSplashBg(),
          ),
          new Offstage(
            offstage: !(_status == 2),
            child: _bannerList.isEmpty
                ? new Container()
                : new Swiper(
                    autoStart: false,
                    circular: false,
                    indicator: CircleSwiperIndicator(
                      radius: 4.0,
                      padding: EdgeInsets.only(bottom: 30.0),
                      itemColor: Colors.black26,
                    ),
                    children: _bannerList),
          ),
          new Offstage(
            offstage: !(_status == 1),
            child: new Container(
              alignment: Alignment.bottomRight,
              margin: EdgeInsets.all(20.0),
              child: InkWell(
                onTap: () {
                  _goMain();
                },
                child: new Container(
                    padding: EdgeInsets.all(12.0),
                    child: new Text(
                      '$_count 跳转',
                      style: new TextStyle(fontSize: 14.0, color: Colors.white),
                    ),
                    decoration: new BoxDecoration(
                        color: Color(0x66000000),
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        border:
                            new Border.all(width: 0.33, color: Colors.grey))),
              ),
            ),
          )
        ],
      ),
    );
  }
}
