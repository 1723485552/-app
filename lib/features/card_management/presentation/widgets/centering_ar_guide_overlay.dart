import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CenteringArGuideOverlay extends StatefulWidget {
  final VoidCallback onGuideComplete;
  final VoidCallback onDismiss;

  const CenteringArGuideOverlay({
    super.key,
    required this.onGuideComplete,
    required this.onDismiss,
  });

  @override
  State<CenteringArGuideOverlay> createState() => _CenteringArGuideOverlayState();
}

class _CenteringArGuideOverlayState extends State<CenteringArGuideOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _pulseController;

  final List<String> _stepTitles = [
    '步骤 1：卡牌框选与对齐',
    '步骤 2：微调 4 条金边测量线',
    '步骤 3：获取 PSA / BGS 预估分',
  ];

  final List<String> _stepDescs = [
    '将卡牌至于摄像头中央取景框内，保持卡牌与虚线轮廓重合。',
    '拖动上、下、左、右金线，分别切合卡牌印刷内框边缘。',
    '系统自动计算 50/50 或 60/40 居中比率，并预测 10 分概率。',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _nextStep() {
    HapticFeedback.lightImpact();
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      widget.onGuideComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFFFD700);

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.68),
          ),
        ),
        Positioned(
          top: 54,
          right: 20,
          child: TextButton.icon(
            onPressed: widget.onDismiss,
            icon: const Icon(Icons.close, color: Colors.white70, size: 18),
            label: const Text('跳过引导', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 36,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: goldColor.withValues(alpha: 0.5), width: 1.2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _stepTitles[_currentStep],
                  style: const TextStyle(color: goldColor, fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _stepDescs[_currentStep],
                  style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldColor,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(_currentStep < 2 ? '下一步' : '开始实测'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CameraAngleFocusHUD extends StatelessWidget {
  final double pitchAngle;
  final double rollAngle;
  final bool isFocused;
  final bool isLightingGood;

  const CameraAngleFocusHUD({
    super.key,
    this.pitchAngle = 0.8,
    this.rollAngle = -0.4,
    this.isFocused = true,
    this.isLightingGood = true,
  });

  bool get isLevel => pitchAngle.abs() < 2.0 && rollAngle.abs() < 2.0;

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFFFD700);
    final statusColor = isLevel ? Colors.greenAccent : const Color(0xFFFF6B6B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isLevel ? goldColor.withValues(alpha: 0.6) : Colors.redAccent.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.crop_free, color: statusColor, size: 18),
          const SizedBox(width: 8),
          Text(
            isLevel ? '相机水平良好' : '请平放手机',
            style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
