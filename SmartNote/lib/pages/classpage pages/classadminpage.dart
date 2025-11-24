import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClassAdminPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String classID;
  const ClassAdminPage({super.key, required this.data, required this.classID});

  @override
  State<ClassAdminPage> createState() => _ClassAdminPageState();
}

class _ClassAdminPageState extends State<ClassAdminPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome Admin')),
      body: ListView(
        shrinkWrap: true,
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: (widget.data['participants'] as List).length,
            itemBuilder: (context, index) {
              return UserRoleCard(
                userData: widget.data['participants'][index],
                classID: widget.classID,
              );
            },
          ),
        ],
      ),
    );
  }
}

enum UserRole { admin, editor, member, viewer }

class UserRoleCard extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String classID;
  final Function(String email, String role)? onRoleChanged;

  const UserRoleCard({
    super.key,
    required this.userData,
    this.onRoleChanged,
    required this.classID,
  });

  @override
  State<UserRoleCard> createState() => _UserRoleCardState();
}

class _UserRoleCardState extends State<UserRoleCard> {
  late String selectedRole;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.userData['role'] ?? 'viewer';
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color(0xFFDC2626); // Red
      case 'editor':
        return const Color(0xFF2563EB); // Blue
      case 'member':
        return const Color(0xFF16A34A); // Green
      case 'viewer':
        return const Color(0xFF9333EA); // Purple
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.shield;
      case 'editor':
        return Icons.edit;
      case 'member':
        return Icons.person;
      case 'viewer':
        return Icons.visibility;
      default:
        return Icons.person;
    }
  }

  String _getRoleDescription(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Full access to all features';
      case 'editor':
        return 'Can create and edit content';
      case 'member':
        return 'Can view and comment';
      case 'viewer':
        return 'Can only view content';
      default:
        return '';
    }
  }

  void _showRoleSelectionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Select User Role',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  UserRole.values.map((role) {
                    final roleName = role.name;
                    final isSelected = selectedRole.toLowerCase() == roleName;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? _getRoleColor(roleName).withOpacity(0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? _getRoleColor(roleName)
                                  : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getRoleColor(roleName).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getRoleIcon(roleName),
                            color: _getRoleColor(roleName),
                            size: 24,
                          ),
                        ),
                        title: Text(
                          roleName.toUpperCase(),
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                            color:
                                isSelected
                                    ? _getRoleColor(roleName)
                                    : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          _getRoleDescription(roleName),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing:
                            isSelected
                                ? Icon(
                                  Icons.check_circle,
                                  color: _getRoleColor(roleName),
                                )
                                : null,
                        onTap: () {
                          FirebaseFirestore.instance
                              .collection('classes')
                              .doc(widget.classID)
                              .update({
                                'participants': FieldValue.arrayRemove([
                                  {
                                    'email': widget.userData['email'],
                                    'role': selectedRole,
                                  },
                                ]),
                              });
                          FirebaseFirestore.instance
                              .collection('classes')
                              .doc(widget.classID)
                              .update({
                                'participants': FieldValue.arrayUnion([
                                  {
                                    'email': widget.userData['email'],
                                    'role': roleName,
                                  },
                                ]),
                              });
                          setState(() {
                            selectedRole = roleName;
                          });
                          if (widget.onRoleChanged != null) {
                            widget.onRoleChanged!(
                              widget.userData['email'],
                              roleName,
                            );
                          }
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  String _getInitials(String email) {
    if (email.isEmpty) return '?';
    return email[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.userData['email'] ?? 'No email';
    final roleColor = _getRoleColor(selectedRole);

    return Card(
      color: const Color.fromARGB(255, 252, 252, 251),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with initial
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF205B85).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _getInitials(email),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF205B85),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Email and Role Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _getRoleIcon(selectedRole),
                          color: roleColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedRole.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: roleColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getRoleDescription(selectedRole),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Change Role Button
            TextButton.icon(
              onPressed: _showRoleSelectionDialog,
              icon: const Icon(Icons.edit, color: Colors.white, size: 18),
              label: const Text(
                "Change Role",
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  const Color(0xFF205B85),
                ),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: const BorderSide(color: Color(0xFF205B85)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
