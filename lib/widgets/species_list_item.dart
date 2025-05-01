import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/species.dart';

class SpeciesListItemActions {
  final Species species;
  final List<Widget> actions;

  const SpeciesListItemActions({
    required this.species,
    required this.actions,
  });
}

class SpeciesListItem extends StatelessWidget {
  final Species species;
  final SpeciesListItemActions actions;

  const SpeciesListItem({
    Key? key,
    required this.species,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: SvgPicture.asset(
          'assets/svg/${species.icon.isNotEmpty ? species.icon : 'unknown-face.svg'}',
          width: 40,
          height: 40,
          placeholderBuilder: (context) => SvgPicture.asset(
            'assets/svg/unknown-face.svg',
            width: 40,
            height: 40,
          ),
        ),
        title: Text(species.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Culture: ${species.culture}'),
            Text('Traits: ${species.traits.join(', ')}'),
            Text('Stats: VIT ${species.vit}, ATH ${species.ath}, WIL ${species.wil}'),
            Text('Derived: HP ${species.hp}, Life ${species.life}, Power ${species.power}, Def ${species.def}, Speed ${species.speed}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: actions.actions,
        ),
      ),
    );
  }
} 