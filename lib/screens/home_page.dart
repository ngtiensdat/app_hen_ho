import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class CommentsScreen extends StatefulWidget {
  final int postId;
  CommentsScreen({required this.postId});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final response = await supabase
        .from('comments')
        .select()
        .eq('post_id', widget.postId)
        .order('created_at', ascending: false);
    setState(() {
      _comments = response;
      _isLoading = false;
    });
  }

  Future<void> _addComment() async {
    final user = supabase.auth.currentUser;
    if (user == null || _commentController.text.isEmpty) return;

    String username = _formatUsername(user.email!);

    final newComment = {
      'post_id': widget.postId,
      'user_id': user.id,
      'username': username,
      'content': _commentController.text,
      'likes': 0,
      'created_at': DateTime.now().toIso8601String(),
    };

    await supabase.from('comments').insert(newComment);

    setState(() {
      _comments.insert(0, newComment);
      _commentController.clear();
    });
  }

  Future<void> _likeComment(int commentId, int currentLikes) async {
    await supabase
        .from('comments')
        .update({'likes': currentLikes + 1}).eq('id', commentId);
    setState(() {
      _comments.firstWhere((c) => c['id'] == commentId)['likes'] += 1;
    });
  }

  String _formatUsername(String email) {
    String username = email.split('@')[0];
    if (username.length > 3) {
      return username.substring(0, username.length - 3) + "***";
    }
    return username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bình luận"), backgroundColor: Colors.pink),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? Center(child: Text("Chưa có bình luận nào."))
                    : ListView.builder(
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person)),
                            title: Text(comment['username'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(comment['content']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon:
                                      Icon(Icons.thumb_up, color: Colors.pink),
                                  onPressed: () => _likeComment(
                                      comment['id'], comment['likes']),
                                ),
                                Text(comment['likes'].toString()),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed:
                                      () {}, // Tạm thời chưa có chức năng
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  child: Text("Kết bạn",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Viết bình luận...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: CircleBorder(),
                  ),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final supabase = Supabase.instance.client;

  final TextEditingController _postController = TextEditingController();

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
  void initState() {
    super.initState();
    ensureUserExists(); // Kiểm tra và thêm user nếu chưa có
  }

  Future<void> ensureUserExists() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final existingUser =
        await supabase.from('users').select().eq('id', user.id);

    if (existingUser.isEmpty) {
      await supabase.from('users').insert({
        'id': user.id,
        'email': user.email,
        'created_at': DateTime.now().toIso8601String(),
      }).catchError((error) {
        print("Lỗi khi thêm user: $error");
      });
    }
  }

  Future<void> _addPost() async {
    final user = supabase.auth.currentUser;
    if (user == null || _postController.text.isEmpty) return;

    await ensureUserExists(); // Đảm bảo user tồn tại trước khi đăng bài

    await supabase.from('posts').insert({
      'user_id': user.id,
      'username': user.email,
      'content': _postController.text,
      'created_at': DateTime.now().toIso8601String(),
    }).catchError((error) {
      print("Lỗi khi thêm bài viết: $error");
    });

    _postController.clear();
    setState(() {});
  }

  Future<void> _deletePost(int postId) async {
    await supabase.from('posts').delete().eq('id', postId);
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> _fetchPosts() async {
    final response = await supabase
        .from('posts')
        .select()
        .order('created_at', ascending: false);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LoveMatch"),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postController,
                    decoration: InputDecoration(
                      hintText: "Viết bài...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.pink),
                  onPressed: _addPost,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('posts').stream(
                  primaryKey: ['id']).order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data!;
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final currentUser = supabase.auth.currentUser;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(post['username'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                if (currentUser != null &&
                                    post['user_id'] == currentUser.id)
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deletePost(post['id']),
                                  ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text(post['content']),
                            SizedBox(height: 10),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CommentsScreen(postId: post['id']),
                                ),
                              ),
                              child: Text("Bình luận"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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

// Đổi mk
class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _message = "";

  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
      _message = "";
    });

    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.length < 6) {
      setState(() {
        _isLoading = false;
        _message = "Mật khẩu phải có ít nhất 6 ký tự.";
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _isLoading = false;
        _message = "Mật khẩu xác nhận không khớp.";
      });
      return;
    }

    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      setState(() {
        _message = "Đổi mật khẩu thành công!";
      });
    } catch (e) {
      setState(() {
        _message = "Lỗi: ${e.toString()}";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đổi mật khẩu"), backgroundColor: Colors.pink),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nhập mật khẩu mới:", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            TextField(
              controller: _newPasswordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Mật khẩu mới",
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Xác nhận lại mật khẩu:", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Nhập lại mật khẩu",
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Center(
                      child: Text("Cập nhật mật khẩu",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
            SizedBox(height: 10),
            if (_message.isNotEmpty)
              Center(
                child: Text(
                  _message,
                  style: TextStyle(
                      color: _message.contains("thành công")
                          ? Colors.green
                          : Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  String _language = "vi";

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? "vi";
    });
  }

  Future<void> _changeLanguage(String lang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() {
      _language = lang;
    });
  }

  Future<void> _signOut(BuildContext context) async {
    await supabase.auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_language == "vi" ? "Cài đặt" : "Settings"),
          backgroundColor: Colors.pink),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.language, color: Colors.green),
            title:
                Text(_language == "vi" ? "Chọn ngôn ngữ" : "Choose Language"),
            trailing: DropdownButton<String>(
              value: _language,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _changeLanguage(newValue);
                }
              },
              items: [
                DropdownMenuItem(value: "vi", child: Text("🇻🇳 Tiếng Việt")),
                DropdownMenuItem(value: "en", child: Text("🇺🇸 English")),
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.lock, color: Colors.blue),
            title: Text(_language == "vi" ? "Đổi mật khẩu" : "Change Password"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info, color: Colors.green),
            title: Text(_language == "vi"
                ? "Thông tin hệ thống"
                : "System Information"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.privacy_tip, color: Colors.orange),
            title: Text(
                _language == "vi" ? "Chính sách bảo mật" : "Privacy Policy"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.redAccent),
            title: Text(_language == "vi"
                ? "Thông báo & Quyền riêng tư"
                : "Notifications & Privacy"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.help_outline, color: Colors.purple),
            title: Text(
                _language == "vi" ? "Trợ giúp & Hỗ trợ" : "Help & Support"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text(_language == "vi" ? "Đăng xuất" : "Log out"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
