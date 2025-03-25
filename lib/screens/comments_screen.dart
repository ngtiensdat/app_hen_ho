import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentsScreen extends StatefulWidget {
  final int postId;
  CommentsScreen({required this.postId});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = []; // Danh sách bình luận
  bool _isLoading = true; // Trạng thái tải dữ liệu

  @override
  void initState() {
    super.initState();
    _fetchComments(); // Gọi hàm tải bình luận ngay khi vào màn hình
  }

  Future<void> _fetchComments() async {
    final response = await supabase
        .from('comments')
        .select()
        .eq('post_id', widget.postId)
        .order('created_at', ascending: false);
    setState(() {
      _comments = response;
      _isLoading = false; // Dữ liệu đã tải xong
    });
  }

  Future<void> _addComment() async {
    final user = supabase.auth.currentUser;
    if (user == null || _commentController.text.isEmpty) return;

    final newComment = {
      'post_id': widget.postId,
      'user_id': user.id,
      'username': user.email,
      'content': _commentController.text,
      'created_at': DateTime.now().toIso8601String(),
    };

    await supabase.from('comments').insert(newComment);

    setState(() {
      _comments.insert(0, newComment); // Thêm bình luận ngay lập tức
      _commentController.clear(); // Xóa nội dung TextField
    });
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
