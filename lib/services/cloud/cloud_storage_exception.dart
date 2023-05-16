class CloudStorageException implements Exception {
  const CloudStorageException();
}

// C in CRUD
class CouldNotCreateMealException extends CloudStorageException {}

// R in CRUD
class CouldNotGetAllMealException extends CloudStorageException {}

// U in CRUD
class CouldNotUpdateMealException extends CloudStorageException {}

// D in CRUD
class CouldNotDeleteMealException extends CloudStorageException {}
