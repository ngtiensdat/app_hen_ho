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

//Bình luận
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

  Future<void> _sendFriendRequest(String receiverId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // Lấy thông tin người gửi từ bảng users
    final senderData = await supabase
        .from('users')
        .select('full_name, avatar_url')
        .eq('id', user.id)
        .single();

    if (senderData == null) return;

    await supabase.from('friend_requests').insert({
      'sender_id': user.id,
      'receiver_id': receiverId,
      'username': senderData['full_name'],
      'avatar_url': senderData['avatar_url'],
      'status': 'Chờ phản hồi',
      'created_at': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã gửi lời mời kết bạn!')),
    );
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
                                  onPressed: () =>
                                      _sendFriendRequest(comment['user_id']),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue),
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

// Lời mời
class InvitationScreen extends StatefulWidget {
  @override
  _InvitationScreenState createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> invitations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInvitations();
  }

  Future<void> _fetchInvitations() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('friend_requests')
        .select(
            'id, sender_id, status, created_at, users:sender_id(full_name, avatar_url)')
        .eq('receiver_id', user.id)
        .order('created_at', ascending: false); // Sắp xếp mới nhất trước

    if (response.isNotEmpty) {
      setState(() {
        invitations = response.map((invite) {
          final user = invite['users']; // Lấy thông tin người gửi từ bảng users
          return {
            'id': invite['id'],
            'username': user != null
                ? user['full_name'] ?? 'Người dùng ẩn danh'
                : 'Người dùng ẩn danh',
            'avatar': user != null
                ? user['avatar_url'] ?? "https://via.placeholder.com/150"
                : "https://via.placeholder.com/150",
            'status': invite['status'],
            'created_at': invite['created_at']
          };
        }).toList();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _acceptInvite(int index) async {
    await supabase
        .from('friend_requests')
        .update({'status': 'Đã chấp nhận'}).eq('id', invitations[index]['id']);

    setState(() {
      invitations[index]["status"] = "Đã chấp nhận";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bạn đã chấp nhận lời mời kết bạn!")),
    );
  }

  void _declineInvite(int index) async {
    await supabase
        .from('friend_requests')
        .delete()
        .eq('id', invitations[index]['id']);

    setState(() {
      invitations.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bạn đã từ chối lời mời kết bạn.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lời mời kết bạn"),
        backgroundColor: Colors.pink,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : invitations.isEmpty
              ? Center(
                  child: Text("Không có lời mời kết bạn!",
                      style: TextStyle(fontSize: 18, color: Colors.grey)))
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  itemCount: invitations.length,
                  itemBuilder: (context, index) {
                    final invite = invitations[index];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(invite['avatar']),
                        ),
                        title: Text(invite['username'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(invite["status"],
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700])),
                        trailing: invite["status"] == "Chờ phản hồi"
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.check_circle,
                                        color: Colors.green),
                                    onPressed: () => _acceptInvite(index),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () => _declineInvite(index),
                                  ),
                                ],
                              )
                            : Icon(Icons.check, color: Colors.grey),
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

// Trang cá nhân
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  String avatarUrl = "https://via.placeholder.com/150";
  String fullName = "";
  String bio = "";
  TextEditingController bioController = TextEditingController();
  TextEditingController avatarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response = await supabase
          .from('users')
          .select('full_name, avatar_url, bio') // Thêm cột bio
          .eq('id', user.id)
          .single();

      setState(() {
        fullName = response['full_name'] ?? user.email!.split('@')[0];
        avatarUrl = response['avatar_url'] ?? avatarUrl;
        bio = response['bio'] ?? "";
      });
    }
  }

  Future<void> _updateProfile() async {
    avatarController.text = avatarUrl;
    bioController.text = bio;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Cập nhật thông tin"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: avatarController,
                decoration: InputDecoration(labelText: "Nhập link ảnh avatar"),
              ),
              TextField(
                controller: bioController,
                decoration: InputDecoration(labelText: "Nhập mô tả"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = supabase.auth.currentUser;
                if (user != null) {
                  await supabase.from('users').update({
                    'avatar_url': avatarController.text,
                    'bio': bioController.text
                  }).eq('id', user.id);

                  setState(() {
                    avatarUrl = avatarController.text;
                    bio = bioController.text;
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Trang cá nhân"), backgroundColor: Colors.pink),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _updateProfile, // Sửa lại: trước đây gọi _updateAvatar
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(avatarUrl),
              ),
            ),
            SizedBox(height: 16),
            Text(fullName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  _updateProfile, // Sửa lại: Gọi _updateProfile thay vì _updateAvatar
              child: Text("Cập nhật avatar"),
            ),
            SizedBox(height: 8),
            Text("Mô tả:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(bio, style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text("Cập nhật thông tin"),
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
