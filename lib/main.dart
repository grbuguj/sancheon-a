import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:math';
import 'package:image_picker/image_picker.dart'; // 패키지 임포트
import 'dart:io';

void main() => runApp(HwacheonCoupleApp());

class HwacheonCoupleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Pretendard', brightness: Brightness.light),
      home: MainWrapper(),
    );
  }
}

class MainWrapper extends StatefulWidget {
  @override
  _MainWrapperState createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> checklistItems = [
    // --- [카테고리: 낚시 및 방한용품] ---
    {"title": "따뜻한 옷 (방한 필수! 🧣)", "done": false},
    {"title": "두꺼운 여분 양말 (발 시려요! 🧦)", "done": false},
    {"title": "의자 2개 & 낚싯대 🎣", "done": false},
    {"title": "예약 번호 (문자 확인! 🎫)", "done": false},
    {"title": "낚시용 미끼 🐛", "done": false},
    {"title": "핫팩 (주머니용/발바닥용 🔥)", "done": false},

    // --- [카테고리: 장보기 (음식)] ---
    {"title": "소고기 & 차돌박이 🍖🥓", "done": false},
    {"title": "바지락 (조개탕용 🐚)", "done": false},
    {"title": "소주 & 탄산수, 물 🍶🥤", "done": false},
    {"title": "솔의눈 & 레몬즙 🌲🍋", "done": false},
    {"title": "식용 얼음 (하이볼 필수! 🧊)", "done": false},
    {"title": "구워먹는 치즈 🧀", "done": false},
    {"title": "햇반 & 라면 🍚🍜", "done": false},
    {"title": "김치 & 과자 🥬🍪", "done": false},
    {"title": "버섯 & 아스파라거스 🍄🥦", "done": false},
    {"title": "쌈장 & 허브솔트 🧂", "done": false},
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      CoupleHomeScreen(),
      CoupleRoomPage(),
      BattlePage(),
      ChecklistPage(items: checklistItems, onUpdate: () => setState(() {})),
    ];

    return Scaffold(
      body: Stack(
        children: [
          _pages[_selectedIndex],
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      bottom: 20, left: 20, right: 20,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF2D3436),
          borderRadius: BorderRadius.circular(35),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navIcon(Icons.calendar_month, "일정", 0),
            _navIcon(Icons.favorite, "커플룸", 1),
            _navIcon(Icons.emoji_events_rounded, "배틀", 2), // ✅ 아이콘 추가
            _navIcon(Icons.checklist_rtl_rounded, "준비물", 3)
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFFFF758C) : Colors.white54, size: 26),
          Text(label, style: TextStyle(color: isSelected ? const Color(0xFFFF758C) : Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}
class BattlePage extends StatefulWidget {
  @override
  _BattlePageState createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  int jaewoongScore = 0;
  int eunjiScore = 0;
  final List<Widget> _effects = [];

  // ✅ 잡은 물고기를 시각적으로 쌓아주기 위한 리스트 생성
  void _addEffect(TapDownDetails details) {
    final Key effectKey = UniqueKey();
    setState(() {
      _effects.add(
        _HeartAnimation(
          key: effectKey,
          top: details.globalPosition.dy,
          left: details.globalPosition.dx,
          isFish: true,
          onFinished: () {
            setState(() {
              _effects.removeWhere((element) => element.key == effectKey);
            });
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView( // 물고기가 많아질 경우를 대비
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Icon(Icons.phishing, size: 60, color: Colors.blueAccent),
                  const Text("누가 누가 많이 잡나?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),

                  // 점수판 영역
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildScoreColumn("재웅 🐧", jaewoongScore, (v) => setState(() => jaewoongScore = (jaewoongScore + v).clamp(0, 99))),
                      const Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Text("VS", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.redAccent)),
                      ),
                      _buildScoreColumn("은지 🐤", eunjiScore, (v) => setState(() => eunjiScore = (eunjiScore + v).clamp(0, 99))),
                    ],
                  ),
                  // 📜 [최종 확정 내기 룰 보드] - 반응형 수정 버전
                  Container(
                    // 가로 여백을 200 -> 20으로 대폭 줄여서 핸드폰 화면에 꽉 차게 만듭니다.
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2),
                      boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 15)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // 내용물만큼만 높이 차지
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("🏆", style: TextStyle(fontSize: 20)),
                            SizedBox(width: 8),
                            Text("대결 보상", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                            SizedBox(width: 8),
                            Text("🏆", style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        // 규칙들을 감싸는 영역
                        _buildRuleRow("3마리", "상대방 안마 해주기 💆"),
                        _buildRuleRow("5마리", "오늘 설거지 당첨! 🍽️"),
                        _buildRuleRow("7마리", "소원권 1회 (오늘 한정)"),
                        _buildRuleRow("최종승리", "평생 소원권 (거부X) 🎫"),
                        const Divider(height: 30), // 구분선 추가
                        const Text(
                          "* 주의: 산천어 사기 금지, 정직하게 입력할 것!",
                          style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  TextButton(
                    onPressed: () => setState(() { jaewoongScore = 0; eunjiScore = 0; }),
                    child: const Text("게임 리셋 (아이스박스 비우기)", style: TextStyle(color: Colors.grey)),
                  ),

                  const SizedBox(height: 100), // 네비게이션 바 공간 확보
                ],
              ),
            ),
          ),
          ..._effects,
        ],
      ),
    );
  }

  Widget _buildScoreColumn(String name, int score, Function(int) onUpdate) {
    return Column( // ✅ 기존 Container와 width: ... 부분을 삭제했습니다.
      mainAxisSize: MainAxisSize.min, // 내용물만큼만 차지하게 설정
      children: [
        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          width: 100, height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
          ),
          child: Text("$score", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _scoreBtn(Icons.remove, () => onUpdate(-1), Colors.grey[300]!),
            const SizedBox(width: 10),
            GestureDetector(
              onTapDown: (details) {
                onUpdate(1);
                _addEffect(details);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFFF758C), shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // ✅ 물고기 아이스박스 박스
        Container(
          constraints: const BoxConstraints(maxWidth: 120), // 너무 넓어지지 않게 가로 최대치만 설정
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2))
          ),
          child: Wrap(
            alignment: WrapAlignment.center, // 물고기 중앙 정렬
            spacing: 2,
            runSpacing: 2,
            children: List.generate(score, (index) =>
            const Text("🐟", style: TextStyle(fontSize: 16))
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRuleRow(String count, String penalty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(count, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(penalty, style: const TextStyle(fontSize: 14, color: Color(0xFF2D3436), fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _scoreBtn(IconData icon, VoidCallback tap, Color color) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class CoupleHomeScreen extends StatefulWidget {
  @override
  _CoupleHomeScreenState createState() => _CoupleHomeScreenState();
}

class _CoupleHomeScreenState extends State<CoupleHomeScreen> {
  late Timer _timer;
  final ImagePicker _picker = ImagePicker();

  // ✅ 사진 경로 저장 (메모리상 보관)
  Map<int, String> uploadedImages = {};
  final double itemHeight = 240.0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // ✅ 사진첩에서 사진 선택 함수
  Future<void> _pickImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        uploadedImages[index] = image.path;
      });
    }
  }

  // ✅ 누락 없는 풀코스 일정 리스트
  final List<Map<String, dynamic>> schedules = [
    {"time": "06:00", "type": "card", "title": "화천으로 출발! 🚗", "desc": "재웅이는 6시 20분쯤 나오기!", "place": "청라 5단지", "color": const Color(0xFFFF7675)},
    {"time": "06:20", "type": "card", "title": "맥도날드 타임 🍔", "desc": "아침밥 사기 (2시간 40분 소요)", "place": "맥도날드 청라 DT", "color": const Color(0xFFFAB1A0)},
    {"type": "photo", "title": "출발 전 설레는 셀카! 📸"},
    {"time": "08:40", "type": "card", "title": "주차 및 입장 🅿️", "desc": "작년에 갔던 곳 주변 주차!", "place": "화천산천어축제 주차장", "color": const Color(0xFFFFEAA7)},
    {"time": "09:00", "type": "card", "title": "산천어 낚시 🎣", "desc": "미끼 구매하고 낚시 시작! 🐟", "place": "화천산천어축제", "color": const Color(0xFF74B9FF)},
    {"type": "photo", "title": "누가 누가 많이 잡나? 🐟"},
    {"time": "12:00", "type": "card", "title": "점심 식사 & 접수 🍴", "desc": "맨손잡기 접수부터! (선착순)", "place": "화천산천어축제", "color": const Color(0xFF55E6C1)},
    {"time": "13:00", "type": "card", "title": "맨손 잡기 도전! 🙌", "desc": "은지야 꼭 한 마리 잡아줘! 파이팅!", "place": "화천산천어축제", "color": const Color(0xFF00CEC9)},
    {"time": "14:00", "type": "card", "title": "추가 낚시 🎣", "desc": "농특산물교환권 사용하기!", "place": "화천산천어축제", "color": const Color(0xFF81ECEC)},
    {"time": "16:00", "type": "card", "title": "화천 시장 구경 🛒", "desc": "배추 살까? (주차 힘들면 패스!)", "place": "화천시장", "color": const Color(0xFF55E6C1)},
    {"time": "17:00", "type": "card", "title": "숙소로 이동 🏠", "desc": "춘천까지 한 시간 정도 소요!", "place": "세르니띠 펜션", "color": const Color(0xFFD63031)},
    {"type": "photo", "title": "우리들의 즐거운 저녁 ❤️"},
    {"time": "18:00", "type": "card", "title": "펜션 바비큐 🍖", "desc": "은지 취향 조개탕이랑 고기 파티!", "place": "세르니띠 펜션", "color": const Color(0xFFA29BFE)},
    {"time": "20:00", "type": "card", "title": "스파 타임 🛁", "desc": "따뜻하게 하루 마무리", "place": "세르니띠 펜션", "color": const Color(0xFFE84393)},
    {"time": "01/26", "type": "card", "title": "숙소에서 꿀잠자기! 😴", "desc": "축제 끝! 푹 자고 에너지 충전 ❤️", "place": "세르니띠 펜션", "color": const Color(0xFF636E72)},
  ];

  String _getLiveStatus(String timeStr) {
    if (timeStr == "photo") return "";
    DateTime now = DateTime.now();
    DateTime targetDate;

    if (timeStr == "01/26") {
      targetDate = DateTime(2026, 1, 26, 10, 0);
    } else {
      List<String> parts = timeStr.split(":");
      targetDate = DateTime(2026, 1, 25, int.parse(parts[0]), int.parse(parts[1]));
    }

    Duration diff = targetDate.difference(now);

    // 이미 시간이 지났을 때
    if (diff.isNegative) {
      // 1시간 이내면 '진행 중', 그 이상 지났으면 '완료'
      return diff.inHours.abs() < 1 ? "진행 중 🔥" : "완료 ✅";
    }

    // 시간이 남았을 때 (일, 시간, 분, 초 단위로 계산)
    int days = diff.inDays;
    int hours = diff.inHours % 24;
    int minutes = diff.inMinutes % 60;
    int seconds = diff.inSeconds % 60;

    if (days > 0) {
      return "$days일 $hours시간 남음";
    } else if (hours > 0) {
      return "$hours시간 $minutes분 $seconds초 남음";
    } else {
      return "$minutes분 $seconds초 남음";
    }
  }

  double _getCharacterPosition() {
    DateTime now = DateTime.now();
    DateTime startTime = DateTime(2026, 1, 25, 0, 0);
    DateTime endTime = DateTime(2026, 1, 26, 2, 0);
    if (now.isBefore(startTime)) return 0.0;
    if (now.isAfter(endTime)) return schedules.length - 1.0;
    return (now.difference(startTime).inSeconds / endTime.difference(startTime).inSeconds) * (schedules.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    // 1. 현재 화면의 너비를 측정합니다. (반응형 핵심!)
    double screenWidth = MediaQuery.of(context).size.width;
    String topCountdown = _getLiveStatus("06:00");
    double charPos = _getCharacterPosition();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      body: Stack(
        children: [
          _buildHeaderBackground(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildCoupleAppBar(topCountdown),
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      // 도로를 그리는 부분
                      CustomPaint(
                        size: Size(screenWidth, schedules.length * itemHeight),
                        painter: RoadMapPainter(count: schedules.length, itemHeight: itemHeight),
                      ),
                      // 일정 카드들
                      Column(
                        children: List.generate(schedules.length, (index) {
                          if (schedules[index]['type'] == 'photo') {
                            return _buildPhotoStation(index, schedules[index]);
                          }
                          // _buildLargeScheduleCard에도 인덱스 짝홀수를 판단해서 넘겨주면 더 좋습니다.
                          return _buildLargeScheduleCard(index, schedules[index], index % 2 != 0);
                        }),
                      ),
                      // ⭐ 자동차 마커: 이제 screenWidth를 함께 보내줍니다!
                      _buildCoupleMarker(charPos, screenWidth),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🖼️ 사진 업로드 기능이 들어간 액자 위젯
  Widget _buildPhotoStation(int index, Map<String, dynamic> data) {
    String? imagePath = uploadedImages[index];

    return Container(
      height: itemHeight,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () => _pickImage(index),
        child: Transform.rotate(
          angle: index % 2 == 0 ? -0.05 : 0.05,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15)]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  color: Colors.grey[100],
                  child: imagePath != null
                      ? Image.file(File(imagePath), fit: BoxFit.cover)
                      : const Icon(Icons.add_a_photo, color: Colors.grey, size: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  imagePath != null ? "우리의 소중한 기록 ❤️" : data['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 💳 가로로 길어진 대형 일정 카드
  // ✅ 인자를 3개(index, data, isRight) 받도록 수정
  Widget _buildLargeScheduleCard(int index, Map<String, dynamic> data, bool isRight) {
    String status = _getLiveStatus(data['time']);
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: itemHeight,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => _launchMap(data['place']),
        child: Container(
          width: screenWidth * 0.4, // 반응형 너비
          padding: const EdgeInsets.all(18),
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                  color: data['color'].withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8)
              )
            ],
            // 현재 진행 중인 일정은 핑크색 테두리 강조
            border: status.contains("🔥") ? Border.all(color: Colors.pinkAccent, width: 2.5) : null,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(data['time'], style: TextStyle(color: data['color'], fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(data['title'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF2D3436)))
                  ),
                  const SizedBox(height: 4),
                  Text(
                      data['desc'],
                      style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis
                  ),
                  if (status.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                        status,
                        style: TextStyle(
                            fontSize: 10,
                            color: status.contains("초") ? Colors.redAccent : data['color'],
                            fontWeight: FontWeight.bold
                        )
                    ),
                  ]
                ],
              ),
              // 우측 상단 장소 뱃지
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: data['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, size: 10, color: data['color']),
                      const SizedBox(width: 4),
                      Text(
                          data['place'],
                          style: const TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
            child: Image.asset('assets/header_bg.jpg', fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFF758C), Color(0xFFFF7EB3)])))),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.1)]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoupleAppBar(String countdown) {
    final List<Shadow> shadows = [Shadow(offset: const Offset(1, 1), blurRadius: 3.0, color: Colors.blue.withOpacity(0.5))];
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [const Icon(Icons.favorite, color: Colors.pink, size: 20), const SizedBox(width: 8), Text("은지재웅", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: shadows))]),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)), child: Text(countdown.contains("남음") ? countdown.split(" 남음")[0] : countdown, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 15),
            Text("두근두근 2026 \n화천 산천어 대축제", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, shadows: shadows)),
            const SizedBox(height: 5),
            Text("출발까지 $countdown", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.bold, shadows: shadows)),
          ],
        ),
      ),
    );
  }

  Widget _buildCoupleMarker(double pos, double screenWidth) {
    // 1. 현재 어떤 칸에 있는지 확인
    int currentIdx = pos.floor();
    double t = pos - currentIdx; // 한 칸 안에서의 진행도 (0.0 ~ 1.0)

    // 2. 도로의 중심점 계산
    double centerX = screenWidth / 2;
    double curveXOffset = (currentIdx % 2 == 0) ? 50 : -50; // Painter와 동일한 굴곡값

    // 3. ⭐ 핵심: 2차 베지에 곡선 공식 (도로와 100% 일치시킴)
    // 자동차의 가로 위치(x)를 도로 곡선 공식에 대입합니다.
    double xPos = (1 - t) * (1 - t) * centerX +
        2 * (1 - t) * t * (centerX + curveXOffset) +
        t * t * centerX;

    // 4. 세로 위치 계산
    double yOffset = pos * itemHeight + (itemHeight / 2);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      top: yOffset - 35, // 자동차 아이콘 크기 절반만큼 보정
      left: xPos - 35,  // 자동차 아이콘 중앙 정렬
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.pinkAccent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.3), blurRadius: 5)],
            ),
            child: const Text("우리 위치", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
          const Icon(Icons.directions_car, color: Colors.blueAccent, size: 30),
        ],
      ),
    );
  }

  Future<void> _launchMap(String place) async {
    final Uri url = Uri.parse('https://map.naver.com/v5/search/${Uri.encodeComponent(place)}');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

class RoadMapPainter extends CustomPainter {
  final int count;
  final double itemHeight;
  RoadMapPainter({required this.count, required this.itemHeight});

  @override
  void paint(Canvas canvas, Size size) {
    Paint roadPaint = Paint()..color = Colors.blue.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = 45..strokeCap = StrokeCap.round;
    Paint linePaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round;

    Path path = Path();
    double centerX = size.width / 2;
    path.moveTo(centerX, 0);

    for (int i = 0; i < count; i++) {
      double nextY = (i + 1) * itemHeight + (itemHeight / 2);
      bool isLeft = i % 2 == 0;
      path.quadraticBezierTo(isLeft ? centerX - 160 : centerX + 160, (i * itemHeight + nextY) / 2, centerX, nextY);
      _drawDecor(canvas, centerX + (isLeft ? 100 : -120), i * itemHeight + 50, i % 3 == 0 ? "🌲" : (i % 3 == 1 ? "🐟" : "❄️"));
    }

    canvas.drawPath(path, roadPaint);
    canvas.drawPath(path, linePaint);
  }

  void _drawDecor(Canvas canvas, double x, double y, String emoji) {
    TextPainter(text: TextSpan(text: emoji, style: const TextStyle(fontSize: 22)), textDirection: TextDirection.ltr)..layout()..paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class CoupleRoomPage extends StatefulWidget {
  @override
  _CoupleRoomPageState createState() => _CoupleRoomPageState();
}

class _CoupleRoomPageState extends State<CoupleRoomPage> with TickerProviderStateMixin {
  // 하트 애니메이션을 위한 리스트
  final List<Widget> _hearts = [];

  void _addHeart(TapDownDetails details) {
    // 터치한 위치 좌표 가져오기
    double top = details.globalPosition.dy;
    double left = details.globalPosition.dx;

    // 새로운 하트 위젯 생성
    final Key heartKey = UniqueKey();
    setState(() {
      _hearts.add(
        _HeartAnimation(
          key: heartKey,
          top: top,
          left: left,
          onFinished: () {
            // 애니메이션 끝나면 리스트에서 제거 (메모리 관리)
            setState(() {
              _hearts.removeWhere((element) => element.key == heartKey);
            });
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime anniversary = DateTime(2022, 12, 23);
    final DateTime now = DateTime.now();
    final int daysTogether = now.difference(anniversary).inDays + 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack( // 하트 애니메이션을 위에 쌓기 위해 Stack 사용
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 📸 이미지 클릭 감지용 GestureDetector
                GestureDetector(
                  onTapDown: (details) => _addHeart(details),
                  child: Container(
                    width: 170, // 클릭 영역을 위해 살짝 키움
                    height: 170,
                    alignment: Alignment.center,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFF758C), width: 5),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFFFF758C).withOpacity(0.3),
                              blurRadius: 25,
                              spreadRadius: 8
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/couple_profile.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.favorite, size: 80, color: Color(0xFFFF758C)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text("은지 ❤️ 재웅", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                    "우리 사랑한 지 $daysTogether일째",
                    style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFFFF758C),
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5
                    )
                ),
                const SizedBox(height: 40),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FE),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    "화천에서 산천어 많이 잡고\n맛난거 먹으면서 행복한 시간 보내자!\n은지야 운전 조심해! 사랑해❤️",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF444444), height: 1.8, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          // 💖 생성된 하트들이 표시되는 레이어
          ..._hearts,
        ],
      ),
    );
  }
}

// 개별 하트 애니메이션 위젯
class _HeartAnimation extends StatefulWidget {
  final double top;
  final double left;
  final bool isFish; // ✅ 물고기인지 하트인지 구분하는 변수 추가
  final VoidCallback onFinished;

  const _HeartAnimation({
    Key? key,
    required this.top,
    required this.left,
    required this.onFinished,
    this.isFish = false // ✅ 기본값은 하트로 설정
  }) : super(key: key);

  @override
  __HeartAnimationState createState() => __HeartAnimationState();
}

class __HeartAnimationState extends State<_HeartAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _moveUp;
  late double _randomX;

  @override
  void initState() {
    super.initState();
    _randomX = (Random().nextDouble() - 0.5) * 120;
    _controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)));
    _moveUp = Tween<double>(begin: 0.0, end: -180.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward().then((_) => widget.onFinished());
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: widget.top + _moveUp.value - 40,
          left: widget.left + (_randomX * _controller.value),
          child: Opacity(
            opacity: _opacity.value,
            child: Icon(
              // ✅ 조건문으로 아이콘과 색상을 변경합니다.
              widget.isFish ? Icons.phishing : Icons.favorite,
              color: widget.isFish ? Colors.blueAccent : Colors.pinkAccent.withOpacity(0.8),
              size: 35 + (25 * _controller.value),
            ),
          ),
        );
      },
    );
  }
}

class ChecklistPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final VoidCallback onUpdate;

  ChecklistPage({required this.items, required this.onUpdate});

  @override
  _ChecklistPageState createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 탭을 2개(준비물 / 장보기)로 나눕니다.
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // 데이터를 카테고리별로 분류 (title에 포함된 키워드로 판별)
    final packingItems = widget.items.where((e) =>
    e['title'].contains("옷") || e['title'].contains("양말") ||
        e['title'].contains("의자") || e['title'].contains("예약") ||
        e['title'].contains("미끼") || e['title'].contains("핫팩")).toList();

    final shoppingItems = widget.items.where((e) => !packingItems.contains(e)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text("화천 정복 리스트 🔥", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF758C),
          labelColor: const Color(0xFFFF758C),
          unselectedLabelColor: Colors.grey,
          indicatorWeight: 3,
          tabs: const [
            Tab(child: Text("집에서 챙길 것 🎒", style: TextStyle(fontWeight: FontWeight.bold))),
            Tab(child: Text("마트에서 살 것 🛒", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListSection(packingItems),  // 탭 1: 준비물
          _buildListSection(shoppingItems), // 탭 2: 장보기
        ],
      ),
    );
  }

  // 리스트를 그리는 공통 위젯 (카드가 더 얇고 깔끔하게 수정됨)
  Widget _buildListSection(List<Map<String, dynamic>> items) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        bool isDone = item['done'];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10), // 간격을 좁혀서 더 많이 보이게
          decoration: BoxDecoration(
            color: isDone ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDone ? Colors.transparent : Colors.black12),
          ),
          child: CheckboxListTile(
            dense: true, // ✅ 카드를 더 얇게 만듦
            visualDensity: VisualDensity.compact,
            title: Text(
              item['title'],
              style: TextStyle(
                fontSize: 15,
                fontWeight: isDone ? FontWeight.normal : FontWeight.w600,
                color: isDone ? Colors.grey : Colors.black87,
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            value: isDone,
            activeColor: const Color(0xFFFF758C),
            onChanged: (val) {
              setState(() => item['done'] = val);
              widget.onUpdate();
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        );
      },
    );
  }
}