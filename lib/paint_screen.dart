import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:skribbl_clone/models/my_custom_painter.dart';
import 'package:skribbl_clone/models/touch_points.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenFrom;
  PaintScreen({required this.data, required this.screenFrom});

  @override
  _PaintScreenState createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late IO.Socket _socket;
  Map dataOfRoom = {};
  List<TouchPoints> points = [];
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;
  List<Widget>textBlankWidget=[];
  ScrollController _scrollController = ScrollController();
  TextEditingController controller = TextEditingController();
  List<Map> messages = [];
  int guessedUserCtr = 0;
  int _start = 60;

  @override
  void initState() {
    super.initState();
    connect();
  }

  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (int i = 0; i < text.length; i++) {
      textBlankWidget.add(const Text('_', style: TextStyle(fontSize: 30)));
    }
  }

  void connect() {
    _socket = IO.io('http://192.0.0.2:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket.connect();

    if (widget.screenFrom == 'createRoom') {
      _socket.emit('create-game', widget.data);
    } else {
      _socket.emit('join-game', widget.data);
    }

    //listening to socket
    _socket.onConnect((data) {
      print('connected!');
      _socket.on('updateRoom', (roomData) {
        print(roomData['word']);
        setState(() {
          renderTextBlank(roomData['word']);
          dataOfRoom = roomData;
        });
        if (roomData['isJoin'] != true) {
          // startTimer();
        }
      });
    });

    _socket.on('points', (point) {
      if (point['details'] != null) {
        setState(() {
          points.add(TouchPoints(
              points:
                  Offset((point['details']['dx']).toDouble(), (point['details']['dy']).toDouble()),
              paint: Paint()
                ..strokeCap = strokeType
                ..isAntiAlias = true
                ..color = selectedColor.withOpacity(opacity)
                ..strokeWidth = strokeWidth));
        });
      }
    });

    _socket.on('msg', (msgData) {
      setState(() {
        messages.add(msgData);
        guessedUserCtr = msgData['guessedUserCtr'];
      });
      if (guessedUserCtr == dataOfRoom['players'].length - 1) {
        _socket.emit('change-turn', dataOfRoom['name']);
      }
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 40,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut
      );
    });

    _socket.on('color-change', (colorString) {
      int value = int.parse(colorString, radix: 16);
      Color otherColor = Color(value);
      setState(() {
        selectedColor = otherColor;
      });
    });

    _socket.on('stroke-width', (value) {
      setState(() {
        strokeWidth = value.toDouble();});
    });

    _socket.on('clear-screen', (data) {
      setState(() {
        points.clear();
      });
    });


  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    void selectColor() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Choose Color'),
                content: SingleChildScrollView(
                    child: BlockPicker(
                        pickerColor: selectedColor,
                        onColorChanged: (color) {
                          String colorString = color.toString();
                          String valueString = colorString.split('(0x')[1].split(')')[0];
                          print(colorString);
                          print(valueString);
                          Map map = {'color': valueString, 'roomName': dataOfRoom['name']};
                          _socket.emit('color-change', map);
                        })),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Close'))
                ],
              ));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: width,
                height: height * 0.55,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    print(details.localPosition.dx);
                    _socket.emit('paint', {
                      'details': {
                        'dx': details.localPosition.dx,
                        'dy': details.localPosition.dy,
                      },
                      'roomName': widget.data['name'],
                    });
                  },
                  onPanStart: (details) {
                    print(details.localPosition.dx);
                    _socket.emit('paint', {
                      'details': {
                        'dx': details.localPosition.dx,
                        'dy': details.localPosition.dy,
                      },
                      'roomName': widget.data['name'],
                    });
                  },
                  onPanEnd: (details) {
                    print(details.localPosition.dx);
                    _socket.emit('paint', {
                      'details': {
                        'dx': details.localPosition.dx,
                        'dy': details.localPosition.dy,
                      },
                      'roomName': widget.data['name'],
                    });
                  },
                  child: SizedBox.expand(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: RepaintBoundary(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: MyCustomPainter(pointsList: points),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.color_lens_outlined),
                    color: selectedColor,
                    onPressed: () {selectColor();},
                  ),
                  Expanded(
                    child: Slider(
                      min: 1.0,
                      max: 10,
                      label: "Strokewidth $strokeWidth",
                      activeColor: selectedColor,
                      value: strokeWidth,
                      onChanged: (double value) {
                        Map map = {'value': value, 'roomName': dataOfRoom['name']};
                        _socket.emit('stroke-width', map);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.layers_clear),
                    color: selectedColor,
                    onPressed: () {
                      _socket.emit(
                          'clean-screen', dataOfRoom['name']);
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: textBlankWidget,
              ),
              Container(
                height: MediaQuery.of(context).size.height*0.3,
                child: ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index){
                      var msg = messages[index].values;
                      print(msg);
                      return ListTile(
                        title: Text(
                          msg.elementAt(0),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 19,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          msg.elementAt(1),
                          style: TextStyle(
                              color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                margin:
                EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  // readOnly: isTextInputReadOnly,
                  controller: controller,
                  onSubmitted: (value) {
                    print(value.trim());
                    if (value.trim().isNotEmpty) {
                      Map map = {
                        'username': widget.data['nickname'],
                        'msg': value.trim(),
                        'word': dataOfRoom['word'],
                        'roomName': widget.data['name'],
                        'guessedUserCtr': guessedUserCtr,
                        // 'totalTime': 60,
                        // 'timeTaken': 60 - _start,
                      };
                      _socket.emit('msg', map);
                      controller.clear();
                    }
                  },
                  autocorrect: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: Colors.transparent),
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: const Color(0xffF5F5FA),
                    hintText: 'Your Guess',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                )),
          )
        ],
      ),
    );
  }
}
