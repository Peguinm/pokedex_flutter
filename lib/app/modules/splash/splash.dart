import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex_app/app/core/exceptions/message_exception.dart';
import 'package:pokedex_app/app/core/ui/messenger.dart';
import 'package:pokedex_app/app/repositories/pokemon_name_list_repository.dart';
import 'package:pokedex_app/app/repositories/pokemon_repository.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  void _loadNameList() async {
    PokemonNameListRepository(pokemonRepository: context.read<PokemonRepository>()).loadNameList();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        try {
          _loadNameList();
        } on MessageException catch (e) {
          Messenger.of(context).showError(e.message);
        } finally {
          Navigator.pushNamed(context, '/pokedex/');
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
