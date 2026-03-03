import 'package:flutter/material.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';

class SeatReservationPage extends StatefulWidget {
  const SeatReservationPage({super.key});

  @override
  State<SeatReservationPage> createState() => _SeatReservationPageState();
}

class _SeatReservationPageState extends State<SeatReservationPage> {
  String _selectedFloor = '三楼';
  String _selectedZone = 'A区';
  int? _selectedSeat;

  final List<String> _floors = ['一楼', '二楼', '三楼', '四楼'];
  final List<String> _zones = ['A区', 'B区', 'C区', 'D区'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CampusAppBar(title: '座位预约', showBackButton: true),
      body: Column(
        children: [
          _buildFilters(),
          const SizedBox(height: AppSpacing.lg),
          _buildSeatLegend(),
          const SizedBox(height: AppSpacing.lg),
          Expanded(child: _buildSeatGrid()),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDropdown(_selectedFloor, _floors, (val) {
            setState(() {
              _selectedFloor = val!;
            });
          }),
          _buildDropdown(_selectedZone, _zones, (val) {
            setState(() {
              _selectedZone = val!;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String current,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.greyLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          items: options
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: AppTextStyles.bodySmall),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSeatLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.green, '空闲'),
        const SizedBox(width: 20),
        _buildLegendItem(Colors.red, '占用'),
        const SizedBox(width: 20),
        _buildLegendItem(AppColors.primary, '已选'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildSeatGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: 48,
      itemBuilder: (context, index) {
        bool isOccupied = index % 5 == 0 || index % 7 == 0;
        bool isSelected = _selectedSeat == index;

        return GestureDetector(
          onTap: isOccupied
              ? null
              : () {
                  setState(() {
                    _selectedSeat = isSelected ? null : index;
                  });
                },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isOccupied
                        ? Colors.red.withOpacity(0.3)
                        : Colors.green.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isOccupied ? Colors.red : Colors.green),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? Colors.white
                      : (isOccupied ? Colors.red : Colors.green),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedSeat != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.chair, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '已选: $_selectedFloor $_selectedZone ${_selectedSeat! + 1}号座',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          CampusButton(
            text: _selectedSeat == null ? '请选择座位' : '确认预约',
            onPressed: () {},
            isDisabled: _selectedSeat == null,
          ),
        ],
      ),
    );
  }
}
