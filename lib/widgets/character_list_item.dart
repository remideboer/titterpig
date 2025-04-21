import 'package:flutter/material.dart';
import 'package:ttrpg_character_manager/models/character.dart';
import 'package:ttrpg_character_manager/theme/app_theme.dart';
import 'package:ttrpg_character_manager/utils/name_formatter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

class CharacterListItem extends StatelessWidget {
  final Character character;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const CharacterListItem({
    super.key,
    required this.character,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  Widget _buildAvatar(BuildContext context, bool isDead) {
    return Stack(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDead ? Colors.grey.withOpacity(0.5) : Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          child: ClipOval(
            child: character.avatarPath != null
                ? ColorFiltered(
                    colorFilter: isDead
                        ? const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 1, 0,
                          ])
                        : const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.srcOver,
                          ),
                    child: Image.file(
                      File(character.avatarPath!),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 30,
                    color: isDead ? Colors.grey : null,
                  ),
          ),
        ),
        if (isDead)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: SvgPicture.asset(
                'assets/svg/death-skull.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        if (!isDead && character.species.icon.isNotEmpty)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
              child: SvgPicture.asset(
                'assets/svg/${character.species.icon}',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDead = character.isDead;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: isDead ? RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.grey.withOpacity(0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ) : null,
      child: ListTile(
        leading: _buildAvatar(context, isDead),
        title: Text(
          '${NameFormatter.formatName(character.name)} (${character.species.name})',
          style: AppTheme.titleStyle.copyWith(
            fontSize: 18,
            color: isDead ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          'HP: ${character.hpStat.current}/${character.hpStat.max} | '
          'LIFE: ${character.lifeStat.current}/${character.lifeStat.max} | '
          'POWER: ${character.powerStat.current}/${character.powerStat.max}',
          style: AppTheme.bodyStyle.copyWith(
            color: isDead ? Colors.grey : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: isDead ? Colors.grey : null),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: isDead ? Colors.grey : null),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
} 