import 'package:flutter/material.dart';
import 'package:ttrpg_character_manager/models/character.dart';
import 'package:ttrpg_character_manager/theme/app_theme.dart';
import 'package:ttrpg_character_manager/utils/name_formatter.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDead = character.lifeStat.current == 0;

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
        leading: SizedBox(
          width: 24,
          height: 24,
          child: isDead
              ? SvgPicture.asset(
                  'assets/svg/death-skull.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    Colors.grey,
                    BlendMode.srcIn,
                  ),
                )
              : character.species.icon.isNotEmpty
                  ? SvgPicture.asset(
                      'assets/svg/${character.species.icon}',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                      placeholderBuilder: (context) => const SizedBox(
                        width: 24,
                        height: 24,
                      ),
                    )
                  : const SizedBox(
                      width: 24,
                      height: 24,
                    ),
        ),
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
          style: AppTheme.subtitleStyle.copyWith(
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