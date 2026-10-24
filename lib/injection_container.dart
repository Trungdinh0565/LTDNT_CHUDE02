import 'package:get_it/get_it.dart';

import 'Data/repository_impl.dart';
import 'Domain/stopWatch_repository.dart';
import 'Domain/stopWatch_usecase.dart';
import 'Presentation/stopWatch_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerFactory<StopWatchRepository>(
    () => StopWatchRepositoryImpl(),
  );

  getIt.registerFactory<StopWatchUseCase>(
    () => StopWatchUseCase(getIt<StopWatchRepository>()),
  );

  getIt.registerFactory<StopWatchCubit>(
    () => StopWatchCubit(getIt<StopWatchUseCase>()),
  );
}