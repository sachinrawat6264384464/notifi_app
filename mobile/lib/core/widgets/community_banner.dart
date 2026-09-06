import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_scheduler_mobile/core/theme/app_theme.dart';

class CommunityBanner extends StatelessWidget {
  const CommunityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.textPrimary,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'COMMUNITY',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'Connect with 1,000+ AI Engineers, Builders & Founders',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'JOIN DISCORD COMMUNITY',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
