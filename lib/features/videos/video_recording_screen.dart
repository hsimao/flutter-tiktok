import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tiktok_clone/constants/gaps.dart';
import 'package:tiktok_clone/constants/sizes.dart';
import 'package:tiktok_clone/features/videos/video_preview_screen.dart';
import 'package:tiktok_clone/features/videos/widgets/camera_control_buttons.dart';

class VideoRecordingScreen extends StatefulWidget {
  static const String routeName = 'postVideo';
  static const String routePath = '/upload';

  const VideoRecordingScreen({super.key});

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _hasPermission = false;

  bool _isSelfieMode = false;

  bool _appActivated = true;

  // 避免相機尚未初始化前就渲染相機畫面使用
  bool _showCamera = false;

  late FlashMode _flashMode;

  double zoomLevel = 0.0;
  late double minZoomLevel;
  late double maxZoomLevel;

  late final AnimationController _buttonAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  late final Animation<double> _buttonAnimation =
      Tween(begin: 1.0, end: 1.3).animate(_buttonAnimationController);

  late final AnimationController _progressAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
    lowerBound: 0.0,
    upperBound: 1.0,
  );

  late CameraController _cameraController;

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      return;
    }

    _cameraController = CameraController(
      cameras[_isSelfieMode ? 1 : 0],
      ResolutionPreset.ultraHigh,
      enableAudio: false,
    );

    await _cameraController.initialize();

    // NOTE: 只有 iOS 才需有作用, 提早調用此方法可降低剛開始錄影時的延遲
    await _cameraController.prepareForVideoRecording();

    _flashMode = _cameraController.value.flashMode;

    // NOTE: 渲染畫面必須再有調用相機初始化後才能顯示, 以及有調用到 _cameraController 相關的變數
    _showCamera = cameras.isNotEmpty;

    // 相機縮放參數
    minZoomLevel = await _cameraController.getMinZoomLevel();
    maxZoomLevel = await _cameraController.getMaxZoomLevel();

    setState(() {});
  }

  Future<void> initPermissions() async {
    final cameraPermission = await Permission.camera.request();
    final micPermission = await Permission.microphone.request();

    // NOTE: Android 會有兩個不同拒絕的狀態，一個是拒絕，一個是永久拒絕
    final cameraDenied =
        cameraPermission.isDenied || cameraPermission.isPermanentlyDenied;

    final micDenied =
        micPermission.isDenied || micPermission.isPermanentlyDenied;

    if (!cameraDenied && !micDenied) {
      _hasPermission = true;
      await initCamera();
      setState(() {});
    }
  }

  void _toggleSelfieMode() async {
    _isSelfieMode = !_isSelfieMode;
    await initCamera();
    setState(() {});
  }

  Future<void> _setFlashMode(FlashMode newFlashMode) async {
    await _cameraController.setFlashMode(newFlashMode);
    _flashMode = newFlashMode;
    setState(() {});
  }

  Future<void> _startRecording(TapDownDetails _) async {
    if (_cameraController.value.isRecordingVideo) return;

    await _cameraController.startVideoRecording();

    _buttonAnimationController.forward();
    _progressAnimationController.forward();
  }

  Future<void> _stopRecording() async {
    if (!_cameraController.value.isRecordingVideo) return;

    _buttonAnimationController.reverse();
    _progressAnimationController.reset();

    final video = await _cameraController.stopVideoRecording();

    // 重置相機 zoomLevel
    zoomLevel = minZoomLevel;
    await _cameraController.setZoomLevel(minZoomLevel);
    setState(() {});

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPreviewScreen(
          video: video,
          isPicked: true,
        ),
      ),
    );
  }

  // 相機縮放
  Future<void> _onZoomInOut(DragUpdateDetails details) async {
    double deltaY = details.delta.dy;

    // 根據滑動方向更新 zoomLevel
    if (deltaY > 0) {
      // 向下鏡頭拉遠
      zoomLevel = zoomLevel - 0.05;
    } else if (deltaY < 0) {
      // 向上鏡頭拉近
      zoomLevel = zoomLevel + 0.05;
    } else {
      // 沒有垂直滑動，不做任何事情
      return;
    }

    // 限制 zoomLevel 範圍
    zoomLevel = zoomLevel.clamp(minZoomLevel, maxZoomLevel);

    // 同步到相機
    await _cameraController.setZoomLevel(zoomLevel);

    setState(() {});
  }

  Future<void> _onPickVideoPressed() async {
    final video = await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (video == null) return;

    print(video);
  }

  @override
  initState() {
    super.initState();
    initPermissions();

    // 監聽用戶是否離開 app
    WidgetsBinding.instance.addObserver(this);

    // 只要 CircularProgress 有變化就會觸發 setState
    _progressAnimationController.addListener(() {
      setState(() {});
    });

    // CircularProgress 動畫結束後觸發
    _progressAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _stopRecording();
      }
    });
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    _progressAnimationController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!_hasPermission) return;
    if (!_cameraController.value.isInitialized) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _appActivated = true;
        await initPermissions();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _appActivated = false;
        setState(() {});
        // 從 widget 樹移除 CameraPreview 後必須將其釋放。
        // setState 的順序很重要
        _cameraController.dispose();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: !_hasPermission
            ? const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Initializing...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Sizes.size20,
                    ),
                  ),
                  Gaps.v20,
                  CircularProgressIndicator.adaptive(),
                ],
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  if (_appActivated && _showCamera)
                    CameraPreview(_cameraController),
                  if (_showCamera)
                    Positioned(
                      top: Sizes.size56,
                      right: Sizes.size20,
                      child: CameraControlButtons(
                        flashMode: _flashMode,
                        setFlashMode: _setFlashMode,
                        toggleSelfieMode: _toggleSelfieMode,
                      ),
                    ),
                  Positioned(
                    width: MediaQuery.of(context).size.width,
                    bottom: Sizes.size40,
                    child: Row(
                      children: [
                        const Spacer(),
                        GestureDetector(
                          onPanUpdate: (detalis) => _onZoomInOut(detalis),
                          onTapDown: _startRecording,
                          onPanEnd: (detail) => _stopRecording(),
                          onTapUp: (details) => _stopRecording(),
                          child: ScaleTransition(
                            scale: _buttonAnimation,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: Sizes.size80 + Sizes.size14,
                                  height: Sizes.size80 + Sizes.size14,
                                  child: CircularProgressIndicator(
                                    color: Colors.red.shade400,
                                    strokeWidth: Sizes.size6,
                                    value: _progressAnimationController.value,
                                  ),
                                ),
                                Container(
                                  width: Sizes.size80,
                                  height: Sizes.size80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red.shade500,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: IconButton(
                              onPressed: _onPickVideoPressed,
                              icon: const FaIcon(
                                FontAwesomeIcons.image,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
