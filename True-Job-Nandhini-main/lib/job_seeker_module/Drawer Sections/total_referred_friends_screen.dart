import 'package:flutter/material.dart';

class TotalReferredFriendsScreen extends StatelessWidget {
  const TotalReferredFriendsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data based on the design
    final List<Map<String, dynamic>> referredFriends = [
      {
        'name': 'Priya Sharma',
        'date': 'Joined on 24 Apr 2026',
        'coins': '20 Coins',
        'avatarType': 'image',
        'avatarData': 'assets/gif/walkthrough 1.gif',
      },
      {
        'name': 'Akhil Mohan',
        'date': 'Joined on 23 Apr 2026',
        'coins': '20 Coins',
        'avatarType': 'text',
        'avatarData': 'AM',
        'color': const Color(0xFF2B5CBF),
      },
      {
        'name': 'Harish',
        'date': 'Joined on 22 Apr 2026',
        'coins': '20 Coins',
        'avatarType': 'image',
        'avatarData': 'assets/gif/walkthrough 2.gif',
      },
      {
        'name': 'John',
        'date': 'Joined on 20 Apr 2026',
        'coins': '20 Coins',
        'avatarType': 'image',
        'avatarData': 'assets/gif/walkthrough 3.gif',
      },
      {
        'name': 'Thanu',
        'date': 'Joined on 20 Apr 2026',
        'coins': '20 Coins',
        'avatarType': 'image',
        'avatarData': 'assets/gif/walkthrough 1.gif',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 16,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Refer & Earn',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/image/coin.png', height: 18, width: 18),
                const SizedBox(width: 6),
                const Text(
                  '85',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green.shade100, width: 1),
                    ),
                    child: Icon(Icons.sync, color: Colors.green.shade400, size: 16),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Total Referred Friends',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '107',
                    style: TextStyle(
                      color: Color(0xFF255EC7),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // List of friends
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: referredFriends.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade100,
                height: 32,
              ),
              itemBuilder: (context, index) {
                final friend = referredFriends[index];
                return Row(
                  children: [
                    // Avatar
                    if (friend['avatarType'] == 'image')
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(friend['avatarData']),
                        backgroundColor: Colors.grey.shade200,
                      )
                    else
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: friend['color'],
                        child: Text(
                          friend['avatarData'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    // Name and Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            friend['name'],
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            friend['date'],
                            style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Coins
                    Row(
                      children: [
                        Image.asset('assets/image/coin.png', height: 20, width: 20),
                        const SizedBox(width: 6),
                        Text(
                          friend['coins'],
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
