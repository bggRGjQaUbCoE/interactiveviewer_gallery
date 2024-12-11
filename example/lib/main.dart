import 'package:cached_network_image/cached_network_image.dart';
import 'package:example/display_gesture_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:interactiveviewer_gallery/hero_dialog_route.dart';
import 'package:interactiveviewer_gallery/interactiveviewer_gallery.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InteraGallery Demo',
      // DisplayGesture is just debug, please remove it when use
      home: DisplayGesture(
        child: InteractiveviewDemoPage(),
      ),
    );
  }
}

class DemoSourceEntity {
  int id;
  DemoSourceEntityType type;
  String? url;
  String? previewUrl;
  Color? color;

  DemoSourceEntity({
    required this.id,
    this.type = DemoSourceEntityType.image,
    this.url,
    this.previewUrl,
    this.color,
  });
}

class InteractiveviewDemoPage extends StatefulWidget {
  static final String sName = "/";

  @override
  _InteractiveviewDemoPageState createState() =>
      _InteractiveviewDemoPageState();
}

enum DemoSourceEntityType { image, video }

class _InteractiveviewDemoPageState extends State<InteractiveviewDemoPage> {
  List<DemoSourceEntity> sourceList = [
    DemoSourceEntity(
      id: 0,
      // url: 'http://file.jinxianyun.com/inter_06.jpg',
      color: Colors.blue,
    ),
    DemoSourceEntity(
      id: 1,
      // url: 'http://file.jinxianyun.com/inter_05.jpg',
      color: Colors.teal,
    ),
    DemoSourceEntity(
      id: 2,
      // url: 'http://file.jinxianyun.com/inter_02.jpg',
      color: Colors.amber,
    ),
    // DemoSourceEntity(3, 'image', 'http://file.jinxianyun.com/inter_03.gif'),
    // DemoSourceEntity(4, 'video', 'http://file.jinxianyun.com/inter_04.mp4',
    //     previewUrl: 'http://file.jinxianyun.com/inter_04_pre.png'),
    // DemoSourceEntity(5, 'video',
    //     'http://file.jinxianyun.com/6438BF272694486859D5DE899DD2D823.mp4',
    //     previewUrl: 'http://file.jinxianyun.com/102.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('InteractiveviewerGallery Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Wrap(
          children: sourceList.map((source) => _buildItem(source)).toList(),
        ),
      ),
    );
  }

  Widget _buildItem(DemoSourceEntity source) {
    return Hero(
      tag: source.id,
      placeholderBuilder: (BuildContext context, Size heroSize, Widget child) {
        // keep building the image since the images can be visible in the
        // background of the image gallery
        return child;
      },
      child: GestureDetector(
        onTap: () => _openGallery(source),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (source.url != null || source.previewUrl != null)
              CachedNetworkImage(
                imageUrl: source.url ?? source.previewUrl ?? '',
                fit: BoxFit.cover,
                width: 100,
                height: 100,
              )
            else if (source.color != null)
              Container(
                height: 100,
                width: 100,
                color: source.color!,
              ),
            if (source.type == DemoSourceEntityType.video)
              Icon(
                Icons.play_arrow,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }

  void _openGallery(DemoSourceEntity source) {
    Navigator.of(context).push(
      HeroDialogRoute<void>(
        // DisplayGesture is just debug, please remove it when use
        builder: (BuildContext context) => DisplayGesture(
          child: InteractiveviewerGallery<DemoSourceEntity>(
            sources: sourceList,
            initIndex: sourceList.indexOf(source),
            itemBuilder: itemBuilder,
            onPageChanged: (int pageIndex) {
              print("nell-pageIndex:$pageIndex");
            },
          ),
        ),
      ),
    );
  }

  Widget itemBuilder(BuildContext context, int index, bool isFocus) {
    DemoSourceEntity sourceEntity = sourceList[index];
    if (sourceEntity.type == 'video') {
      return DemoVideoItem(
        sourceEntity,
        isFocus: isFocus,
      );
    } else {
      return DemoImageItem(sourceEntity);
    }
  }
}

class DemoImageItem extends StatefulWidget {
  final DemoSourceEntity source;

  DemoImageItem(this.source);

  @override
  _DemoImageItemState createState() => _DemoImageItemState();
}

class _DemoImageItemState extends State<DemoImageItem> {
  @override
  void initState() {
    super.initState();
    print('initState: ${widget.source.id}');
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose: ${widget.source.id}');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: Center(
        child: Hero(
          tag: widget.source.id,
          child: widget.source.url != null
              ? CachedNetworkImage(
                  imageUrl: widget.source.url!,
                  fit: BoxFit.contain,
                )
              : widget.source.color != null
                  ? Container(
                      height: 100,
                      width: 100,
                      color: widget.source.color!,
                    )
                  : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class DemoVideoItem extends StatefulWidget {
  final DemoSourceEntity source;
  final bool? isFocus;

  DemoVideoItem(this.source, {this.isFocus});

  @override
  _DemoVideoItemState createState() => _DemoVideoItemState();
}

class _DemoVideoItemState extends State<DemoVideoItem> {
  VideoPlayerController? _controller;
  late VoidCallback listener;
  String? localFileName;

  _DemoVideoItemState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  @override
  void initState() {
    super.initState();
    print('initState: ${widget.source.id}');
    init();
  }

  init() async {
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.source.url!));
    // loop play
    _controller!.setLooping(true);
    await _controller!.initialize();
    setState(() {});
    _controller!.addListener(listener);
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose: ${widget.source.id}');
    _controller!.removeListener(listener);
    _controller?.pause();
    _controller?.dispose();
  }

  @override
  void didUpdateWidget(covariant DemoVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isFocus! && !widget.isFocus!) {
      // pause
      _controller?.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller!.value.isInitialized
        ? Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                  });
                },
                child: Hero(
                  tag: widget.source.id,
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
              _controller!.value.isPlaying == true
                  ? SizedBox()
                  : IgnorePointer(
                      ignoring: true,
                      child: Icon(
                        Icons.play_arrow,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
            ],
          )
        : Theme(
            data: ThemeData(
                cupertinoOverrideTheme:
                    CupertinoThemeData(brightness: Brightness.dark)),
            child: CupertinoActivityIndicator(radius: 30));
  }
}
