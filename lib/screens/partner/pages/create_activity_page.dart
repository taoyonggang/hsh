import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../controllers/activity_controller.dart';
import '../../../models/partner/partner_group.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/tag_selector_widget.dart';
import 'package:intl/intl.dart';

class CreateActivityPage extends StatefulWidget {
  final PartnerGroup? partnerGroup;

  const CreateActivityPage({super.key, this.partnerGroup});

  @override
  _CreateActivityPageState createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final ActivityController _controller = ActivityController();

  String _title = '';
  String _description = '';
  String _coverImageUrl = '';
  DateTime _startDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay _startTime = TimeOfDay(hour: 10, minute: 0);
  DateTime _endDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay _endTime = TimeOfDay(hour: 12, minute: 0);
  String _location = '';
  bool _isOnline = false;
  int _maxParticipants = 10;
  bool _isSignUpRequired = true;
  double _fee = 0;
  List<String> _selectedTags = [];
  bool _isLoading = false;

  // 预设标签列表
  final List<String> _availableTags = [
    '旅行',
    '美食',
    '读书会',
    '户外',
    '健身',
    '游戏',
    '音乐会',
    '电影',
    '摄影',
    '手工',
    '课程',
    '交友',
    '养生',
    '亲子',
    '展览',
    '讲座',
    '聚会',
    '志愿者',
    '比赛',
    '休闲',
    '品鉴',
    '沙龙',
    '运动',
    '其他',
  ];

  @override
  void initState() {
    super.initState();
    // 如果是从搭子详情页创建活动，预设搭子信息
    if (widget.partnerGroup != null) {
      _selectedTags = List.from(widget.partnerGroup!.tags.take(3)); // 最多选取3个标签
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('创建活动'),
        actions: [
          _isLoading
              ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
              : TextButton(
                onPressed: _createActivity,
                child: Text('发布', style: TextStyle(color: Colors.white)),
              ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderTitle('基本信息'),
                      SizedBox(height: 16),
                      _buildTitleField(),
                      SizedBox(height: 16),
                      _buildDescriptionField(),
                      SizedBox(height: 24),
                      _buildHeaderTitle('活动封面'),
                      SizedBox(height: 16),
                      ImagePickerWidget(
                        initialImageUrl: _coverImageUrl,
                        onImageSelected: (String url) {
                          setState(() {
                            _coverImageUrl = url;
                          });
                        },
                      ),
                      SizedBox(height: 24),
                      _buildHeaderTitle('活动时间'),
                      SizedBox(height: 16),
                      _buildDateTimeSelectors(),
                      SizedBox(height: 24),
                      _buildHeaderTitle('活动地点'),
                      SizedBox(height: 16),
                      _buildLocationSelector(),
                      SizedBox(height: 24),
                      _buildHeaderTitle('活动设置'),
                      SizedBox(height: 16),
                      _buildActivitySettings(),
                      SizedBox(height: 24),
                      _buildHeaderTitle('活动标签'),
                      SizedBox(height: 4),
                      Text(
                        '选择合适的标签，让更多人发现你的活动',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      TagSelectorWidget(
                        availableTags: _availableTags,
                        selectedTags: _selectedTags,
                        maxSelection: 5,
                        onTagsChanged: (List<String> tags) {
                          setState(() {
                            _selectedTags = tags;
                          });
                        },
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildHeaderTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: '活动名称',
        hintText: '输入活动名称，最多20个字',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      maxLength: 20,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入活动名称';
        }
        return null;
      },
      onSaved: (value) {
        _title = value?.trim() ?? '';
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: '活动介绍',
        hintText: '介绍一下你的活动内容、亮点等',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        alignLabelWithHint: true,
      ),
      maxLength: 500,
      maxLines: 5,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入活动介绍';
        }
        return null;
      },
      onSaved: (value) {
        _description = value?.trim() ?? '';
      },
    );
  }

  Widget _buildDateTimeSelectors() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(
                label: '开始日期',
                selectedDate: _startDate,
                onDateChanged: (date) {
                  setState(() {
                    _startDate = date;
                    // 如果结束日期早于开始日期，更新结束日期
                    if (_endDate.isBefore(_startDate)) {
                      _endDate = _startDate;
                    }
                  });
                },
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildTimeSelector(
                label: '开始时间',
                selectedTime: _startTime,
                onTimeChanged: (time) {
                  setState(() {
                    _startTime = time;

                    // 如果同一天且结束时间早于开始时间，更新结束时间
                    if (_startDate.year == _endDate.year &&
                            _startDate.month == _endDate.month &&
                            _startDate.day == _endDate.day &&
                            _startTime.hour > _endTime.hour ||
                        (_startTime.hour == _endTime.hour &&
                            _startTime.minute >= _endTime.minute)) {
                      _endTime = TimeOfDay(
                        hour: (_startTime.hour + 1) % 24,
                        minute: _startTime.minute,
                      );
                    }
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(
                label: '结束日期',
                selectedDate: _endDate,
                onDateChanged: (date) {
                  // 确保结束日期不早于开始日期
                  if (!date.isBefore(_startDate)) {
                    setState(() {
                      _endDate = date;
                    });
                  }
                },
                minDate: _startDate,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildTimeSelector(
                label: '结束时间',
                selectedTime: _endTime,
                onTimeChanged: (time) {
                  // 如果同一天，确保结束时间不早于开始时间
                  if (_startDate.year == _endDate.year &&
                      _startDate.month == _endDate.month &&
                      _startDate.day == _endDate.day) {
                    if (time.hour > _startTime.hour ||
                        (time.hour == _startTime.hour &&
                            time.minute > _startTime.minute)) {
                      setState(() {
                        _endTime = time;
                      });
                    }
                  } else {
                    setState(() {
                      _endTime = time;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateChanged,
    DateTime? minDate,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: minDate ?? DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 365)),
        );
        if (picked != null) {
          onDateChanged(picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16),
                SizedBox(width: 8),
                Text(
                  DateFormat('yyyy-MM-dd').format(selectedDate),
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required TimeOfDay selectedTime,
    required ValueChanged<TimeOfDay> onTimeChanged,
  }) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: selectedTime,
        );
        if (picked != null) {
          onTimeChanged(picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16),
                SizedBox(width: 8),
                Text(
                  selectedTime.format(context),
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Column(
      children: [
        SwitchListTile(
          title: Text('线上活动'),
          subtitle: Text('活动将在线上进行，无需线下地点'),
          value: _isOnline,
          activeColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onChanged: (value) {
            setState(() {
              _isOnline = value;
              if (_isOnline) {
                _location = '线上活动';
              } else {
                _location = '';
              }
            });
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: _isOnline ? '线上活动链接' : '活动地点',
            hintText: _isOnline ? '输入会议链接、直播间地址等' : '输入详细地点，方便参与者找到',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: _isOnline ? null : Icon(Icons.location_on),
          ),
          initialValue: _location,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return _isOnline ? '请输入活动链接' : '请输入活动地点';
            }
            return null;
          },
          onChanged: (value) {
            _location = value;
          },
        ),
      ],
    );
  }

  Widget _buildActivitySettings() {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          color: Colors.grey[100],
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '参与人数上限',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton<int>(
                        value: _maxParticipants,
                        underline: SizedBox(),
                        items:
                            [5, 10, 15, 20, 30, 50, 100].map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text('$value 人'),
                              );
                            }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _maxParticipants = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '活动费用',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 120,
                      height: 40,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Text('¥'),
                          SizedBox(width: 4),
                          Expanded(
                            child: TextFormField(
                              initialValue: _fee.toString(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) {
                                try {
                                  _fee = double.parse(value);
                                } catch (e) {
                                  _fee = 0;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        SwitchListTile(
          title: Text('需要报名'),
          subtitle: Text('成员需要提前报名才能参加活动'),
          value: _isSignUpRequired,
          activeColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onChanged: (value) {
            setState(() {
              _isSignUpRequired = value;
            });
          },
        ),
      ],
    );
  }

  Future<void> _createActivity() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_coverImageUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('请上传活动封面')));
      return;
    }

    if (_selectedTags.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('请至少选择一个标签')));
      return;
    }

    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    try {
      // 构建开始和结束时间
      final startDateTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final success = await _controller.createActivity(
        title: _title,
        description: _description,
        coverImageUrl: _coverImageUrl,
        startTime: startDateTime.toIso8601String(),
        endTime: endDateTime.toIso8601String(),
        location: _location,
        isOnline: _isOnline,
        maxParticipants: _maxParticipants,
        isSignUpRequired: _isSignUpRequired,
        fee: _fee,
        tags: _selectedTags,
        partnerGroupId: widget.partnerGroup?.id,
      );

      if (success) {
        Navigator.of(context).pop(true); // 返回并刷新
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('活动创建成功')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('创建失败，请稍后重试')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('创建失败: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
