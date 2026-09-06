import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_scheduler_mobile/core/theme/app_theme.dart';

class BotmartzHeader extends StatefulWidget implements PreferredSizeWidget {
  const BotmartzHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  State<BotmartzHeader> createState() => _BotmartzHeaderState();
}

class _BotmartzHeaderState extends State<BotmartzHeader> {
  String _activeTab = 'Home';

  Widget _buildNavLink(String label) {
    final isActive = _activeTab == label;
    return InkWell(
      onTap: () {
        setState(() => _activeTab = label);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? AppTheme.primaryColor : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: isActive ? 20 : 0,
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      height: 72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.softBlue,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: const Icon(Icons.psychology_alt_rounded, color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'BOTMARTZ ',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'AI',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'SOLUTIONS',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Center Navigation Links (Desktop/Tablet)
          if (isDesktop)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNavLink('Home'),
                _buildNavLink('Services'),
                _buildNavLink('Work'),
                _buildNavLink('Engineering Insights'),
                _buildNavLink('Community'),
              ],
            ),

          // Right Action Button
          ElevatedButton.icon(
            onPressed: () {
              // Talk to an AI Architect Modal / Navigation
            },
            icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
            label: const Text('Talk to an AI Architect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
