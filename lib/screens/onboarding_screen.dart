import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

const _kOnboardingDone = 'onboarding_done_v1';

Future<bool> hasSeenOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kOnboardingDone) ?? false;
}

Future<void> markOnboardingDone() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kOnboardingDone, true);
}

// ─── Slide content ───────────────────────────────────────────────────────────

class _Slide {
  final IconData icon;
  final List<_DecorItem> decor;
  final String headline;
  final String body;
  final Color accent;
  final _ImageAnim anim;
  const _Slide({
    required this.icon,
    required this.headline,
    required this.body,
    required this.accent,
    this.decor = const [],
    this.anim = _ImageAnim.float,
  });
}

class _DecorItem {
  final IconData icon;
  final double size;
  final double dx; // -1.0 to 1.0 relative to center
  final double dy;
  final double opacity;
  const _DecorItem({required this.icon, required this.size, required this.dx, required this.dy, this.opacity = 0.55});
}

enum _ImageAnim { float, pulse, tilt, drift }

const _slides = [
  _Slide(
    icon: Icons.balance_rounded,
    decor: [
      _DecorItem(icon: Icons.home_rounded, size: 18, dx: -0.85, dy: -0.70, opacity: 0.45),
      _DecorItem(icon: Icons.people_rounded, size: 16, dx: 0.80, dy: -0.65, opacity: 0.40),
      _DecorItem(icon: Icons.check_circle_rounded, size: 14, dx: 0.75, dy: 0.72, opacity: 0.35),
    ],
    headline: 'Welcome to Split Fair',
    body: 'Finally, an app that settles the age-old question:\n"Why is Chad paying the same rent as me when his room has a window AND a closet?"\n\nSpoiler: he shouldn\'t be.',
    accent: AppColors.primary,
    anim: _ImageAnim.pulse,
  ),
  _Slide(
    icon: Icons.square_foot_rounded,
    decor: [
      _DecorItem(icon: Icons.straighten_rounded, size: 16, dx: -0.80, dy: -0.68, opacity: 0.45),
      _DecorItem(icon: Icons.calculate_rounded, size: 18, dx: 0.82, dy: -0.60, opacity: 0.40),
      _DecorItem(icon: Icons.bar_chart_rounded, size: 14, dx: -0.70, dy: 0.75, opacity: 0.35),
    ],
    headline: 'Size Matters',
    body: 'Enter each room\'s square footage and we do the math.\n\nThe person with 80 extra square feet of personal kingdom doesn\'t get to split 50/50. That\'s not splitting fairly — that\'s just splitting in Chad\'s favor.',
    accent: Color(0xFF378ADD),
    anim: _ImageAnim.drift,
  ),
  _Slide(
    icon: Icons.wb_sunny_rounded,
    decor: [
      _DecorItem(icon: Icons.bathtub_rounded, size: 17, dx: -0.82, dy: -0.65, opacity: 0.45),
      _DecorItem(icon: Icons.local_parking_rounded, size: 16, dx: 0.80, dy: -0.62, opacity: 0.40),
      _DecorItem(icon: Icons.deck_rounded, size: 14, dx: 0.72, dy: 0.70, opacity: 0.35),
    ],
    headline: 'Natural Light Tax',
    body: 'Got a room with floor-to-ceiling windows?\n\nSlide that natural light score up. The person living next to the boiler in a windowless cube deserves a discount. It\'s only fair.',
    accent: AppColors.accent,
    anim: _ImageAnim.tilt,
  ),
  _Slide(
    icon: Icons.bookmark_added_rounded,
    decor: [
      _DecorItem(icon: Icons.save_rounded, size: 16, dx: -0.80, dy: -0.68, opacity: 0.45),
      _DecorItem(icon: Icons.people_alt_rounded, size: 18, dx: 0.80, dy: -0.60, opacity: 0.40),
      _DecorItem(icon: Icons.sync_rounded, size: 14, dx: -0.68, dy: 0.72, opacity: 0.35),
    ],
    headline: 'Save Your Configs',
    body: 'Moving in with new roommates? Save your setup.\n\nBecause Tyler is joining in March, Priya is leaving in June, and you are NOT doing this math by hand again. Future you will thank present you.',
    accent: Color(0xFF7F77DD),
    anim: _ImageAnim.float,
  ),
  _Slide(
    icon: Icons.picture_as_pdf_rounded,
    decor: [
      _DecorItem(icon: Icons.gavel_rounded, size: 17, dx: -0.80, dy: -0.65, opacity: 0.45),
      _DecorItem(icon: Icons.thumb_up_rounded, size: 16, dx: 0.80, dy: -0.62, opacity: 0.40),
      _DecorItem(icon: Icons.emoji_events_rounded, size: 14, dx: 0.70, dy: 0.70, opacity: 0.35),
    ],
    headline: 'This Is Not Legal Advice',
    body: 'But it IS math. And math wins arguments.\n\nNext time someone says "just split it evenly," pull out a PDF with their name on it and a number that is not 50%.\n\nGood luck. You\'ve got this.',
    accent: AppColors.primary,
    anim: _ImageAnim.pulse,
  ),
];

// ─── Screen ──────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await markOnboardingDone();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_page];
    final isLast = _page == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (_, index) => _SlidePage(
                  slide: _slides[index],
                  isActive: index == _page,
                ),
              ),
            ),

            // Dots + CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      final active = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? slide.accent : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: slide.accent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: slide.accent.withOpacity(0.30),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _next,
                        child: Container(
                          height: 56,
                          alignment: Alignment.center,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              isLast ? "Let's settle this" : 'Next',
                              key: ValueKey(isLast),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Individual slide page ────────────────────────────────────────────────────

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  final bool isActive;
  const _SlidePage({required this.slide, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Artwork ──────────────────────────────────────────────────────
          SizedBox(
            height: 220,
            child: _AnimatedIllustration(
              slide: slide,
              isActive: isActive,
            ),
          ),

          const SizedBox(height: 36),

          // ── Headline ─────────────────────────────────────────────────────
          Text(
            slide.headline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(duration: 380.ms, delay: 100.ms)
              .slideY(begin: 0.12, end: 0, duration: 380.ms, delay: 100.ms),

          const SizedBox(height: 18),

          // ── Body ─────────────────────────────────────────────────────────
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.5,
              color: AppColors.textSecondary,
              height: 1.65,
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(duration: 420.ms, delay: 180.ms)
              .slideY(begin: 0.10, end: 0, duration: 420.ms, delay: 180.ms),
        ],
      ),
    );
  }
}

// ─── Professional icon illustration with animation ───────────────────────────

class _AnimatedIllustration extends StatefulWidget {
  final _Slide slide;
  final bool isActive;
  const _AnimatedIllustration({required this.slide, required this.isActive});

  @override
  State<_AnimatedIllustration> createState() => _AnimatedIllustrationState();
}

class _AnimatedIllustrationState extends State<_AnimatedIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loopCtrl;
  late final Animation<double> _loopAnim;

  @override
  void initState() {
    super.initState();
    _loopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _loopAnim = CurvedAnimation(parent: _loopCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _loopCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.slide.accent;

    // Build illustration: concentric circles + main icon + floating decor icons
    Widget illustration = SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [accent.withOpacity(0.10), accent.withOpacity(0.0)],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
          // Mid ring
          Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.08),
              border: Border.all(color: accent.withOpacity(0.14), width: 1.5),
            ),
          ),
          // Inner filled circle
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.13),
            ),
          ),
          // Main icon
          Icon(widget.slide.icon, size: 48, color: accent),

          // Floating decorative icons
          ...widget.slide.decor.map((d) {
            return Positioned.fill(
              child: Align(
                alignment: Alignment(d.dx, d.dy),
                child: Container(
                  width: d.size + 14,
                  height: d.size + 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withOpacity(0.10),
                    border: Border.all(color: accent.withOpacity(0.18), width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Icon(d.icon, size: d.size, color: accent.withOpacity(d.opacity)),
                ),
              ),
            );
          }),
        ],
      ),
    );

    // Continuous loop animation
    Widget looped = AnimatedBuilder(
      animation: _loopAnim,
      builder: (_, child) {
        switch (widget.slide.anim) {
          case _ImageAnim.float:
            return Transform.translate(
              offset: Offset(0, -10 * _loopAnim.value),
              child: child,
            );
          case _ImageAnim.pulse:
            final scale = 1.0 + 0.04 * _loopAnim.value;
            return Transform.scale(scale: scale, child: child);
          case _ImageAnim.tilt:
            final angle = 0.04 * (_loopAnim.value - 0.5);
            return Transform.rotate(angle: angle, child: child);
          case _ImageAnim.drift:
            return Transform.translate(
              offset: Offset(6 * (_loopAnim.value - 0.5), -8 * _loopAnim.value),
              child: child,
            );
        }
      },
      child: illustration,
    );

    // Entrance animation when slide becomes active
    return looped
        .animate(target: widget.isActive ? 1 : 0)
        .fadeIn(duration: 450.ms)
        .scale(
          begin: const Offset(0.82, 0.82),
          end: const Offset(1.0, 1.0),
          duration: 500.ms,
          curve: Curves.elasticOut,
        )
        .slideY(begin: 0.08, end: 0, duration: 400.ms);
  }
}
