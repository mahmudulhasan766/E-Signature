import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// Base abstract class for all use cases in the application
///
/// [Type] - The return type of the use case
/// [Params] - The parameter type for the use case
///
/// Example:
/// ```dart
/// class GetUserUseCase implements UseCase<User, GetUserParams> {
///   @override
///   Future<Either<Failure, User>> call(GetUserParams params) async {
///     // implementation
///   }
/// }
/// ```
abstract class UseCase<Type, Params> {
  /// Executes the use case with given parameters
  /// Returns Either<Failure, Type> for functional error handling
  Future<Either<Failure, Type>> call(Params params);
}

/// Special parameter class for use cases that don't need parameters
///
/// Example:
/// ```dart
/// class LogoutUseCase implements UseCase<void, NoParams> {
///   @override
///   Future<Either<Failure, void>> call(NoParams params) async {
///     // implementation
///   }
/// }
/// ```
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

// ==================== AUTHENTICATION USE CASES ====================
