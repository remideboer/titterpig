import 'package:flutter/material.dart';
import 'ability_admin_screen.dart';
import 'species_admin_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Abilities'),
            Tab(text: 'Species'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AbilityAdminScreen(),
          SpeciesAdminScreen(),
        ],
      ),
    );
  }
} 