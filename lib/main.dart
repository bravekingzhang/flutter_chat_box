import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatgpt/bloc/conversation_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_chatgpt/app_bloc_observer.dart';
import 'package:flutter_chatgpt/cubit/setting_cubit.dart';
import 'package:flutter_chatgpt/route.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory());
  GetIt.instance.registerSingleton<UserSettingCubit>(UserSettingCubit());
  Bloc.observer = const AppBlocObserver();
  runApp(BlocProvider(
    create: (context) => GetIt.instance.get<UserSettingCubit>(),
    child: BlocBuilder<UserSettingCubit, UserSettingState>(
      builder: (context, state) {
        return MaterialApp.router(
          theme: state.themeData,
          routerConfig: gRouter,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: BlocProvider.of<UserSettingCubit>(context).state.locale,
          builder: EasyLoading.init(),
          debugShowCheckedModeBanner: false,
        );
      },
    ),
  ));
}
