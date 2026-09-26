import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

/// Immersive LIGHT-THEME profile screen for Belayet Hossain.
/// Data sourced from https://www.belayet.pro.bd/
class BelayetProfileScreen extends StatefulWidget {
  const BelayetProfileScreen({super.key});

  @override
  State<BelayetProfileScreen> createState() => _BelayetProfileScreenState();
}

class _BelayetProfileScreenState extends State<BelayetProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  // ─── Profile Data ────────────────────────────────────────────────────────
  static const String _photoUrl =
      'https://www.belayet.pro.bd/wp-content/themes/belayet-theme/assets/images/hero/Belayet.png';
  static const String _website = 'https://www.belayet.pro.bd/';
  static const String _whatsapp = 'https://wa.me/+8801713935162';
  static const String _linkedin = 'https://www.linkedin.com/in/belayeth9234/';
  static const String _behance = 'https://www.behance.net/belayeth923';
  static const String _github = 'https://github.com/error5299';
  static const String _contact = 'https://www.belayet.pro.bd/contact/';

  static const List<_Skill> _skills = [
    _Skill('UI/UX Design', Icons.design_services_rounded, Color(0xFF7C3AED)),
    _Skill('Flutter Dev', Icons.phone_android_rounded, Color(0xFF0EA5E9)),
    _Skill('Web Dev', Icons.web_rounded, Color(0xFF10B981)),
    _Skill('Design Systems', Icons.grid_view_rounded, Color(0xFFF59E0B)),
    _Skill('Prototyping', Icons.layers_rounded, Color(0xFFEC4899)),
    _Skill('Instructor', Icons.school_rounded, Color(0xFF6366F1)),
  ];

  static const List<_Link> _links = [
    _Link('LinkedIn', _linkedin, Icons.work_rounded, Color(0xFF0A66C2), Color(0xFFEBF5FF)),
    _Link('Behance', _behance, Icons.palette_rounded, Color(0xFF1769FF), Color(0xFFEEF3FF)),
    _Link('GitHub', _github, Icons.code_rounded, Color(0xFF24292E), Color(0xFFF0F0F0)),
    _Link('WhatsApp', _whatsapp, Icons.chat_bubble_rounded, Color(0xFF25D366), Color(0xFFECFDF5)),
    _Link("Let's Talk", _contact, Icons.send_rounded, Color(0xFFFF6900), Color(0xFFFFF4ED)),
    _Link('Website', _website, Icons.language_rounded, Color(0xFF0B5233), Color(0xFFEAF5EE)),
  ];

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(parent: _enterController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── Hero SliverAppBar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0B5233),
            elevation: 0.5,
            iconTheme: const IconThemeData(color: Color(0xFF0B5233)),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: _HeroSection(photoUrl: _photoUrl),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + tagline
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Belayet Hossain',
                            style: GoogleFonts.syne(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1F1C),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Product Designer  ·  Developer  ·  Instructor',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF536159),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Available badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF86EFAC)),
                            ),
                            child: Text(
                              '✦  Available for Work',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const _Divider(),

                    // Bio
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel('About Me'),
                          const SizedBox(height: 10),
                          Text(
                            'A passionate creator at the intersection of design and technology. '
                            'I craft purposeful digital experiences — from pixel-perfect UI to '
                            'production-ready Flutter & web apps — and share knowledge as an '
                            'instructor helping the next generation of designers & developers.',
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              height: 1.7,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const _Divider(),

                    // Skills
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _SectionLabel('Skills & Expertise'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _skills.length,
                        separatorBuilder: (ctx, i) => const SizedBox(width: 10),
                        itemBuilder: (ctx, i) => _SkillChip(skill: _skills[i]),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const _Divider(),

                    // Social / Contact links
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _SectionLabel('Connect with Me'),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.98,
                        ),
                        itemCount: _links.length,
                        itemBuilder: (ctx, i) => _LinkCard(
                          link: _links[i],
                          onTap: () => _launch(_links[i].url),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const _Divider(),

                    // Projects
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _SectionLabel('Featured Projects'),
                    ),
                    const SizedBox(height: 14),
                    _ProjectTile(
                      icon: Icons.location_city_rounded,
                      color: const Color(0xFF0B5233),
                      title: 'আমার কুষ্টিয়া',
                      tag: 'Flutter App',
                      desc: 'Smart district guide — transport, tourism, emergency & directory for Kushtia.',
                    ),
                    _ProjectTile(
                      icon: Icons.language_rounded,
                      color: const Color(0xFF7C3AED),
                      title: 'Portfolio Website',
                      tag: 'Web Design',
                      desc: 'Personal brand site with custom WordPress theme & modern web stack.',
                    ),
                    _ProjectTile(
                      icon: Icons.grid_view_rounded,
                      color: const Color(0xFF0EA5E9),
                      title: 'Design System',
                      tag: 'Design',
                      desc: 'Comprehensive component library for scalable product teams.',
                    ),

                    const SizedBox(height: 24),
                    // CTA
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      child: GestureDetector(
                        onTap: () => _launch(_website),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF46AF6A), Color(0xFF0B5233)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0B5233).withAlpha(60),
                                blurRadius: 16,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'View Full Portfolio',
                                style: GoogleFonts.syne(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.open_in_new_rounded,
                                  color: Colors.white, size: 17),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.photoUrl});
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Light green gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEAF5EE), Color(0xFFD4EDE0), Color(0xFFF0F9F4)],
            ),
          ),
        ),
        // Subtle dot pattern
        CustomPaint(painter: _DotPainter()),
        // Profile photo centered
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF46AF6A), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B5233).withAlpha(40),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: const Color(0xFFD4EDE0),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF46AF6A),
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (ctx, err, trace) => Container(
                      color: const Color(0xFFEAF5EE),
                      child: Center(
                        child: Text(
                          'B',
                          style: GoogleFonts.syne(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0B5233),
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
    );
  }
}

// ─── Dot pattern painter ──────────────────────────────────────────────────────
class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0B5233).withAlpha(18)
      ..style = PaintingStyle.fill;
    const step = 24.0;
    for (double x = 0; x <= size.width; x += step) {
      for (double y = 0; y <= size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }
  @override bool shouldRepaint(_DotPainter o) => false;
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 4, height: 18,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF46AF6A), Color(0xFF0B5233)],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
    const SizedBox(width: 10),
    Text(text, style: GoogleFonts.syne(
      fontSize: 16, fontWeight: FontWeight.w700,
      color: const Color(0xFF1A1F1C), letterSpacing: -0.2,
    )),
  ]);
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Divider(
    height: 1, thickness: 1, color: Color(0xFFF0F0F0),
    indent: 20, endIndent: 20,
  );
}

// ─── Skill Chip ───────────────────────────────────────────────────────────────
class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.skill});
  final _Skill skill;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: skill.color.withAlpha(20),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: skill.color.withAlpha(60)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(skill.icon, size: 14, color: skill.color),
      const SizedBox(width: 6),
      Text(skill.label, style: GoogleFonts.inter(
        fontSize: 12.5, fontWeight: FontWeight.w600, color: skill.color)),
    ]),
  );
}

// ─── Link Card ────────────────────────────────────────────────────────────────
class _LinkCard extends StatelessWidget {
  const _LinkCard({required this.link, required this.onTap});
  final _Link link;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: link.bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: link.color.withAlpha(40)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(
              color: link.color.withAlpha(30), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Icon(link.icon, color: link.color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(link.label, style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
          textAlign: TextAlign.center),
      ]),
    ),
  );
}

// ─── Project Tile ─────────────────────────────────────────────────────────────
class _ProjectTile extends StatelessWidget {
  const _ProjectTile({
    required this.icon, required this.color, required this.title,
    required this.tag, required this.desc,
  });
  final IconData icon;
  final Color color;
  final String title, tag, desc;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE5E7EB)),
      boxShadow: [BoxShadow(
        color: Colors.black.withAlpha(8), blurRadius: 6, offset: const Offset(0, 2))],
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: color.withAlpha(20), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 21),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: GoogleFonts.syne(
            fontSize: 14.5, fontWeight: FontWeight.w700, color: const Color(0xFF1A1F1C)))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withAlpha(20), borderRadius: BorderRadius.circular(6)),
            child: Text(tag, style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ),
        ]),
        const SizedBox(height: 4),
        Text(desc, style: GoogleFonts.inter(
          fontSize: 12.5, height: 1.5, color: const Color(0xFF6B7280))),
      ])),
    ]),
  );
}

// ─── Data models ──────────────────────────────────────────────────────────────
class _Skill {
  const _Skill(this.label, this.icon, this.color);
  final String label; final IconData icon; final Color color;
}

class _Link {
  const _Link(this.label, this.url, this.icon, this.color, this.bgColor);
  final String label, url; final IconData icon; final Color color, bgColor;
}
