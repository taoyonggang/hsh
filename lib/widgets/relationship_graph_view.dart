import 'package:flutter/material.dart';
import '../models/relationship/relationship_network.dart';

class RelationshipGraphView extends StatefulWidget {
  final RelationshipNetwork network;
  final String filter;
  final bool editable;
  final Function(String)? onNodeTap;
  final Function(String)? onNodeEdit;
  final Function(String, String)? onEdgeEdit;

  const RelationshipGraphView({
    super.key,
    required this.network,
    this.filter = 'all',
    this.editable = false,
    this.onNodeTap,
    this.onNodeEdit,
    this.onEdgeEdit,
  });

  @override
  _RelationshipGraphViewState createState() => _RelationshipGraphViewState();
}

class _RelationshipGraphViewState extends State<RelationshipGraphView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bubble_chart, size: 60, color: Colors.green),
            SizedBox(height: 16),
            Text(
              '关系网络可视化',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('该组件正在开发中...'),
          ],
        ),
      ),
    );
  }
}
