import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/onboarding_interest.dart';

// Genera automaticamen el Freezed. copyWith() - igualdad automática - pattern matching - clases internas generadas
part 'onboarding_state.freezed.dart';


/// Esta anotación le indica a Freezed que genere
@freezed
class OnboardingState with _$OnboardingState {

  /// Estado inicial de la pantalla.
  const factory OnboardingState.initial() = _Initial;


  /// Estado de carga.
  const factory OnboardingState.loading() = _Loading;


  /// Estado cargado exitosamente. Se guarda la información seleccionada
  const factory OnboardingState.loaded({
    required int currentPage,
    required List<OnboardingInterest> interests,
  }) = _Loaded;


  /// Estado completado. Se usa cuando el usuario ya terminó y se da finalizar
  const factory OnboardingState.completed() = _Completed;


  /// Estado de error.
  const factory OnboardingState.error(String message) = _Error;
}