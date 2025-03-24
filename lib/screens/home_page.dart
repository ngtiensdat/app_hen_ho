import 'package:flutter/material.dart';

void main() {
  runApp(DatingApp());
}

class DatingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
        break;
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => InvitationScreen()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => FavoritesScreen()));
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MessagesScreen()));
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ProfileScreen()));
        break;
      case 5:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SettingsScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LoveMatch"),
        backgroundColor: Colors.pink,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.backpack),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Gặp gỡ người mới!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
              child: Container(
                width: 300,
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://i.scdn.co/image/ab676161000051745a79a6ca8c60e4ec1440be53'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red, size: 40),
                  onPressed: () {},
                ),
                SizedBox(width: 50),
                IconButton(
                  icon: Icon(Icons.favorite, color: Colors.green, size: 40),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_add), label: "Lời mời"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Yêu thích"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Tin nhắn"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: "Trang cá nhân"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Cài đặt"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class InvitationScreen extends StatefulWidget {
  @override
  _InvitationScreenState createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  List<Map<String, dynamic>> invitations = [
    {
      "name": "Ro sé",
      "avatar":
          "https://media-cdn-v2.laodong.vn/Storage/NewsPortal/2020/5/19/806401/Giong-Hat-Cua-Rose-R.jpg",
      "status": "Anh Kim So Huyn ơi <3"
    },
    {
      "name": "CR.7",
      "avatar":
          "https://vcdn1-thethao.vnecdn.net/2024/11/06/ronaldo-jpeg-1730843743-9754-1730843766.jpg?w=460&h=0&q=100&dpr=2&fit=crop&s=VWrHCAYZIY85kxTDDEfpug",
      "status": "Tôi tin cậu liêm giống tôi! Trust u!"
    },
    {
      "name": "Viruss",
      "avatar": "https://cdn-web.onlive.vn/onlive/image-news/unnamed_ujxk.jpg",
      "status": "Chào đồng môn, cùng nhập hội với tôi và Jack nhé!"
    },
  ];

  void _acceptInvite(int index) {
    setState(() {
      invitations[index]["status"] = "Đã chấp nhận";
    });
  }

  void _declineInvite(int index) {
    setState(() {
      invitations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lời mời"),
        backgroundColor: Colors.pink,
      ),
      body: invitations.isEmpty
          ? Center(
              child: Text("Chưa có lời mời nào!",
                  style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
              itemCount: invitations.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(invitations[index]["avatar"]),
                    ),
                    title: Text(invitations[index]["name"],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(invitations[index]["status"]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (invitations[index]["status"] == "Chờ phản hồi") ...[
                          IconButton(
                            icon: Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => _acceptInvite(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _declineInvite(index),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> favoritePeople = [
    {
      "name": "Vịu ơ",
      "avatar":
          "https://bazaarvietnam.vn/wp-content/uploads/2024/04/kim-ji-won-la-dien-vien-duy-nhat-duoc-4-bien-kich-hang-dau-han-quoc-chon-2.jpg",
      "bio": "Diễn viên nổi tiếng Hàn Quốc. Độc toàn thân!",
    },
    {
      "name": "Messi",
      "avatar":
          "https://cdn-i.vtcnews.vn/resize/th/upload/2024/11/20/messi-argentina-3-09243470.JPG",
      "bio": "GOAL!!!",
    },
    {
      "name": "Độ Mixi",
      "avatar":
          "https://afamilycdn.com/150157425591193600/2022/5/4/11813843520253531875985727838702727931676987n-16516437700821194543125.jpg",
      "bio": "Ông bố 3 con.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yêu thích"),
        backgroundColor: Colors.pink,
      ),
      body: favoritePeople.isEmpty
          ? Center(
              child: Text("Bạn chưa thích ai!",
                  style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
              itemCount: favoritePeople.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(favoritePeople[index]["avatar"]),
                    ),
                    title: Text(favoritePeople[index]["name"],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(favoritePeople[index]["bio"]),
                    trailing: Icon(Icons.arrow_forward, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FavoriteDetailScreen(favoritePeople[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class FavoriteDetailScreen extends StatelessWidget {
  final Map<String, dynamic> person;

  FavoriteDetailScreen(this.person);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(person["name"]), backgroundColor: Colors.pink),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(person["avatar"]),
            ),
            SizedBox(height: 20),
            Text(
              person["name"],
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              person["bio"],
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> chatList = [
    {
      "name": "Hoa Hậu nè",
      "avatar":
          "https://thanhnien.mediacdn.vn/Uploaded/thanhlongn/2022_09_25/thuy-tien-3158.jpeg",
      "lastMessage": "Ăn kẹo hum?",
      "unread": 2,
    },
    {
      "name": "V-BTS",
      "avatar":
          "https://cdn.giaoducthoidai.vn/images/87a7b2442062a13f399c8570bdaf2565f5239fccf3fd453f7e1fec76b6c7f98d94f5f6a1c776e9e7940d75b12c0b68e7/v-8869.jpg",
      "lastMessage": "Tối đi ăn không?",
      "unread": 1,
    },
  ];

  final List<Map<String, dynamic>> messageRequests = [
    {
      "name": "J97",
      "avatar": "https://i.ytimg.com/vi/4tYuIU7pLmI/maxresdefault.jpg",
      "lastMessage": "I'm jocker!",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tin nhắn"), backgroundColor: Colors.pink),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (messageRequests.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.all(10),
              child: Text("Tin nhắn chờ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildChatList(messageRequests, context, isRequest: true),
          ],
          Padding(
            padding: EdgeInsets.all(10),
            child: Text("Đang trò chuyện",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(child: _buildChatList(chatList, context)),
        ],
      ),
    );
  }

  Widget _buildChatList(List<Map<String, dynamic>> chats, BuildContext context,
      {bool isRequest = false}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: isRequest ? NeverScrollableScrollPhysics() : null,
      itemCount: chats.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(chats[index]["avatar"]),
            ),
            title: Text(chats[index]["name"],
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(chats[index]["lastMessage"],
                maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: isRequest
                ? ElevatedButton(
                    onPressed: () {}, // Xử lý chấp nhận tin nhắn chờ
                    child: Text("Chấp nhận"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                  )
                : chats[index]["unread"] > 0
                    ? CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Text(chats[index]["unread"].toString(),
                            style:
                                TextStyle(fontSize: 12, color: Colors.white)),
                      )
                    : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(chats[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ChatScreen extends StatelessWidget {
  final Map<String, dynamic> chat;

  ChatScreen(this.chat);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chat["name"]),
        backgroundColor: Colors.pink,
        actions: [
          IconButton(
            icon: Icon(Icons.task_alt),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Nhiệm vụ của bạn và ${chat["name"]}"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                          leading: Icon(Icons.message),
                          title: Text(
                              "1. Nhắn tin với nhau 10 lần để mở khóa tính năng 'Voice'")),
                      ListTile(
                          leading: Icon(Icons.timer),
                          title: Text(
                              "2. Duy trì đoạn chat này 30p để mở khóa tính năng 'Call'")),
                      ListTile(
                          leading: Icon(Icons.image),
                          title: Text(
                              "3. Duy trì nhắn tin trong 7 ngày để mở khóa tính năng 'Ảnh'")),
                      ListTile(
                          leading: Icon(Icons.video_call),
                          title: Text(
                              "4. Duy trì nhắn tin trong 14 ngày để mở khóa tính năng 'Call Video'")),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Đóng"),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(child: Text("Đang trò chuyện với ${chat["name"]}")),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Nhập tin nhắn...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.pink),
                  onPressed: () {
                    // Xử lý gửi tin nhắn
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final String avatarPath = "assets/images/avatar.png"; // Ảnh đại diện
  final String fullName = "Kim So Huyn";
  final String description =
      "Tôi là một người trung thủy, tôi đề cao tình yêu, hãy yêu tôi :)";
  final int likedBy = 120;

  final List<String> uploadedImages = [
    "assets/images/photo1.jpg",
    "assets/images/photo2.jpg",
    "assets/images/photo3.jpg",
    "assets/images/photo4.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Trang cá nhân"), backgroundColor: Colors.pink),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh đại diện + Thông tin
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(avatarPath),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red, size: 20),
                        SizedBox(width: 5),
                        Text("$likedBy người đã thả tim",
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),

            // Mô tả cá nhân
            Text(
              "Mô tả",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 16),

            // Ảnh đã tải lên
            Text(
              "Ảnh đã tải lên",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Expanded(
              child: GridView.builder(
                itemCount: uploadedImages.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        Image.asset(uploadedImages[index], fit: BoxFit.cover),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cài đặt"), backgroundColor: Colors.pink),
      body: ListView(
        children: [
          // Đổi mật khẩu
          ListTile(
            leading: Icon(Icons.lock, color: Colors.blue),
            title: Text("Đổi mật khẩu"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Thêm chức năng đổi mật khẩu
            },
          ),
          Divider(),

          // Thông tin hệ thống
          ListTile(
            leading: Icon(Icons.info, color: Colors.green),
            title: Text("Thông tin hệ thống"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Hiển thị thông tin hệ thống
            },
          ),
          Divider(),

          // Chính sách bảo mật
          ListTile(
            leading: Icon(Icons.privacy_tip, color: Colors.orange),
            title: Text("Chính sách bảo mật"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Hiển thị chính sách bảo mật
            },
          ),
          Divider(),

          // Thông báo & Quyền riêng tư
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.redAccent),
            title: Text("Thông báo & Quyền riêng tư"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Cài đặt thông báo
            },
          ),
          Divider(),

          // Trợ giúp & Hỗ trợ
          ListTile(
            leading: Icon(Icons.help_outline, color: Colors.purple),
            title: Text("Trợ giúp & Hỗ trợ"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Chuyển đến trang hỗ trợ
            },
          ),
          Divider(),

          // Đăng xuất
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Đăng xuất"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Xử lý đăng xuất
            },
          ),
        ],
      ),
    );
  }
}
