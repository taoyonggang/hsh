import 'package:flutter/material.dart';
import '../../../models/partner/matching_profile_1.dart';

class MatchingCard extends StatelessWidget {
  final MatchingProfile profile;
  final bool showBaziAnalysis;
  final VoidCallback onTap;

  const MatchingCard({
    super.key,
    required this.profile,
    required this.showBaziAnalysis,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(context),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfo(),
                  SizedBox(height: 16),
                  _buildTagsSection(),
                  if (showBaziAnalysis) ...[
                    SizedBox(height: 16),
                    _buildBaziAnalysis(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            image: DecorationImage(
              image: NetworkImage(profile.avatarUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${profile.age}岁 · ${profile.location}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (profile.matchScore > 0)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: _getMatchScoreColor(profile.matchScore),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${profile.matchScore}%',
                    style: TextStyle(
                      color: _getMatchScoreColor(profile.matchScore),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        Expanded(
          child: Text(
            profile.bio,
            style: TextStyle(fontSize: 14, height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 16),
        OutlinedButton.icon(
          icon: Icon(Icons.chat_bubble_outline, size: 16),
          label: Text('打招呼'),
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '兴趣标签',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              profile.interests.map((interest) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildBaziAnalysis(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        SizedBox(height: 8),
        Text(
          '八字相合分析',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            _buildElementCompatibility(
              element: '五行',
              score: profile.baziCompatibility.elementScore,
              maxScore: 5,
              primaryColor: Colors.green,
              lightColor: Colors.green[100]!,
            ),
            SizedBox(width: 16),
            _buildElementCompatibility(
              element: '命理',
              score: profile.baziCompatibility.destinyScore,
              maxScore: 5,
              primaryColor: Colors.purple,
              lightColor: Colors.purple[100]!,
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          profile.baziCompatibility.description,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildElementCompatibility({
    required String element,
    required int score,
    required int maxScore,
    required Color primaryColor,
    required Color lightColor,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            element,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(height: 4),
          Row(
            children: List.generate(maxScore, (index) {
              return Container(
                width: 16,
                height: 16,
                margin: EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < score ? primaryColor : lightColor,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _getMatchScoreColor(int score) {
    if (score >= 90) return Colors.red;
    if (score >= 80) return Colors.orange;
    if (score >= 70) return Colors.green;
    return Colors.blue;
  }
}
