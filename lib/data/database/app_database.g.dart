// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProgramsTable extends Programs with TableInfo<$ProgramsTable, Program> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nameKey,
    sortOrder,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'programs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Program> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Program map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Program(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $ProgramsTable createAlias(String alias) {
    return $ProgramsTable(attachedDatabase, alias);
  }
}

class Program extends DataClass implements Insertable<Program> {
  final int id;
  final String name;

  /// Lower-cased name, used to keep names unique ignoring case.
  final String nameKey;
  final int sortOrder;
  final bool archived;
  const Program({
    required this.id,
    required this.name,
    required this.nameKey,
    required this.sortOrder,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['name_key'] = Variable<String>(nameKey);
    map['sort_order'] = Variable<int>(sortOrder);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  ProgramsCompanion toCompanion(bool nullToAbsent) {
    return ProgramsCompanion(
      id: Value(id),
      name: Value(name),
      nameKey: Value(nameKey),
      sortOrder: Value(sortOrder),
      archived: Value(archived),
    );
  }

  factory Program.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Program(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameKey': serializer.toJson<String>(nameKey),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  Program copyWith({
    int? id,
    String? name,
    String? nameKey,
    int? sortOrder,
    bool? archived,
  }) => Program(
    id: id ?? this.id,
    name: name ?? this.name,
    nameKey: nameKey ?? this.nameKey,
    sortOrder: sortOrder ?? this.sortOrder,
    archived: archived ?? this.archived,
  );
  Program copyWithCompanion(ProgramsCompanion data) {
    return Program(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Program(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, nameKey, sortOrder, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Program &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameKey == this.nameKey &&
          other.sortOrder == this.sortOrder &&
          other.archived == this.archived);
}

class ProgramsCompanion extends UpdateCompanion<Program> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nameKey;
  final Value<int> sortOrder;
  final Value<bool> archived;
  const ProgramsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.archived = const Value.absent(),
  });
  ProgramsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String nameKey,
    this.sortOrder = const Value.absent(),
    this.archived = const Value.absent(),
  }) : name = Value(name),
       nameKey = Value(nameKey);
  static Insertable<Program> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameKey,
    Expression<int>? sortOrder,
    Expression<bool>? archived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameKey != null) 'name_key': nameKey,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (archived != null) 'archived': archived,
    });
  }

  ProgramsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? nameKey,
    Value<int>? sortOrder,
    Value<bool>? archived,
  }) {
    return ProgramsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameKey: nameKey ?? this.nameKey,
      sortOrder: sortOrder ?? this.sortOrder,
      archived: archived ?? this.archived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _programIdMeta = const VerificationMeta(
    'programId',
  );
  @override
  late final GeneratedColumn<int> programId = GeneratedColumn<int>(
    'program_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES programs (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ExerciseType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ExerciseType>($ExercisesTable.$convertertype);
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    programId,
    name,
    nameKey,
    type,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('program_id')) {
      context.handle(
        _programIdMeta,
        programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta),
      );
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {programId, nameKey},
  ];
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      programId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}program_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
      type: $ExercisesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ExerciseType, int, int> $convertertype =
      const EnumIndexConverter<ExerciseType>(ExerciseType.values);
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final int id;
  final int programId;
  final String name;
  final String nameKey;
  final ExerciseType type;
  final bool archived;
  const Exercise({
    required this.id,
    required this.programId,
    required this.name,
    required this.nameKey,
    required this.type,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['program_id'] = Variable<int>(programId);
    map['name'] = Variable<String>(name);
    map['name_key'] = Variable<String>(nameKey);
    {
      map['type'] = Variable<int>($ExercisesTable.$convertertype.toSql(type));
    }
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      programId: Value(programId),
      name: Value(name),
      nameKey: Value(nameKey),
      type: Value(type),
      archived: Value(archived),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<int>(json['id']),
      programId: serializer.fromJson<int>(json['programId']),
      name: serializer.fromJson<String>(json['name']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
      type: $ExercisesTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'programId': serializer.toJson<int>(programId),
      'name': serializer.toJson<String>(name),
      'nameKey': serializer.toJson<String>(nameKey),
      'type': serializer.toJson<int>(
        $ExercisesTable.$convertertype.toJson(type),
      ),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  Exercise copyWith({
    int? id,
    int? programId,
    String? name,
    String? nameKey,
    ExerciseType? type,
    bool? archived,
  }) => Exercise(
    id: id ?? this.id,
    programId: programId ?? this.programId,
    name: name ?? this.name,
    nameKey: nameKey ?? this.nameKey,
    type: type ?? this.type,
    archived: archived ?? this.archived,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      programId: data.programId.present ? data.programId.value : this.programId,
      name: data.name.present ? data.name.value : this.name,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      type: data.type.present ? data.type.value : this.type,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('type: $type, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, programId, name, nameKey, type, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.programId == this.programId &&
          other.name == this.name &&
          other.nameKey == this.nameKey &&
          other.type == this.type &&
          other.archived == this.archived);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<int> programId;
  final Value<String> name;
  final Value<String> nameKey;
  final Value<ExerciseType> type;
  final Value<bool> archived;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.programId = const Value.absent(),
    this.name = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.type = const Value.absent(),
    this.archived = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required int programId,
    required String name,
    required String nameKey,
    required ExerciseType type,
    this.archived = const Value.absent(),
  }) : programId = Value(programId),
       name = Value(name),
       nameKey = Value(nameKey),
       type = Value(type);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<int>? programId,
    Expression<String>? name,
    Expression<String>? nameKey,
    Expression<int>? type,
    Expression<bool>? archived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (programId != null) 'program_id': programId,
      if (name != null) 'name': name,
      if (nameKey != null) 'name_key': nameKey,
      if (type != null) 'type': type,
      if (archived != null) 'archived': archived,
    });
  }

  ExercisesCompanion copyWith({
    Value<int>? id,
    Value<int>? programId,
    Value<String>? name,
    Value<String>? nameKey,
    Value<ExerciseType>? type,
    Value<bool>? archived,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      name: name ?? this.name,
      nameKey: nameKey ?? this.nameKey,
      type: type ?? this.type,
      archived: archived ?? this.archived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<int>(programId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $ExercisesTable.$convertertype.toSql(type.value),
      );
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('type: $type, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _programIdMeta = const VerificationMeta(
    'programId',
  );
  @override
  late final GeneratedColumn<int> programId = GeneratedColumn<int>(
    'program_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES programs (id)',
    ),
  );
  static const VerificationMeta _timeInMeta = const VerificationMeta('timeIn');
  @override
  late final GeneratedColumn<int> timeIn = GeneratedColumn<int>(
    'time_in',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeOutMeta = const VerificationMeta(
    'timeOut',
  );
  @override
  late final GeneratedColumn<int> timeOut = GeneratedColumn<int>(
    'time_out',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<int> volume = GeneratedColumn<int>(
    'volume',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _setCountMeta = const VerificationMeta(
    'setCount',
  );
  @override
  late final GeneratedColumn<int> setCount = GeneratedColumn<int>(
    'set_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _summaryPctMeta = const VerificationMeta(
    'summaryPct',
  );
  @override
  late final GeneratedColumn<int> summaryPct = GeneratedColumn<int>(
    'summary_pct',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prevSessionIdMeta = const VerificationMeta(
    'prevSessionId',
  );
  @override
  late final GeneratedColumn<int> prevSessionId = GeneratedColumn<int>(
    'prev_session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    programId,
    timeIn,
    timeOut,
    volume,
    setCount,
    summaryPct,
    prevSessionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('program_id')) {
      context.handle(
        _programIdMeta,
        programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta),
      );
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('time_in')) {
      context.handle(
        _timeInMeta,
        timeIn.isAcceptableOrUnknown(data['time_in']!, _timeInMeta),
      );
    }
    if (data.containsKey('time_out')) {
      context.handle(
        _timeOutMeta,
        timeOut.isAcceptableOrUnknown(data['time_out']!, _timeOutMeta),
      );
    }
    if (data.containsKey('volume')) {
      context.handle(
        _volumeMeta,
        volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta),
      );
    }
    if (data.containsKey('set_count')) {
      context.handle(
        _setCountMeta,
        setCount.isAcceptableOrUnknown(data['set_count']!, _setCountMeta),
      );
    }
    if (data.containsKey('summary_pct')) {
      context.handle(
        _summaryPctMeta,
        summaryPct.isAcceptableOrUnknown(data['summary_pct']!, _summaryPctMeta),
      );
    }
    if (data.containsKey('prev_session_id')) {
      context.handle(
        _prevSessionIdMeta,
        prevSessionId.isAcceptableOrUnknown(
          data['prev_session_id']!,
          _prevSessionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {day},
  ];
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day'],
      )!,
      programId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}program_id'],
      )!,
      timeIn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_in'],
      ),
      timeOut: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_out'],
      ),
      volume: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}volume'],
      )!,
      setCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_count'],
      )!,
      summaryPct: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}summary_pct'],
      ),
      prevSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prev_session_id'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;

  /// Local calendar date as epoch-day. Unique: one session per day in the MVP.
  /// To allow several sessions per day later, drop this unique key.
  final int day;
  final int programId;
  final int? timeIn;
  final int? timeOut;
  final int volume;
  final int setCount;
  final int? summaryPct;
  final int? prevSessionId;
  const Session({
    required this.id,
    required this.day,
    required this.programId,
    this.timeIn,
    this.timeOut,
    required this.volume,
    required this.setCount,
    this.summaryPct,
    this.prevSessionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day'] = Variable<int>(day);
    map['program_id'] = Variable<int>(programId);
    if (!nullToAbsent || timeIn != null) {
      map['time_in'] = Variable<int>(timeIn);
    }
    if (!nullToAbsent || timeOut != null) {
      map['time_out'] = Variable<int>(timeOut);
    }
    map['volume'] = Variable<int>(volume);
    map['set_count'] = Variable<int>(setCount);
    if (!nullToAbsent || summaryPct != null) {
      map['summary_pct'] = Variable<int>(summaryPct);
    }
    if (!nullToAbsent || prevSessionId != null) {
      map['prev_session_id'] = Variable<int>(prevSessionId);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      day: Value(day),
      programId: Value(programId),
      timeIn: timeIn == null && nullToAbsent
          ? const Value.absent()
          : Value(timeIn),
      timeOut: timeOut == null && nullToAbsent
          ? const Value.absent()
          : Value(timeOut),
      volume: Value(volume),
      setCount: Value(setCount),
      summaryPct: summaryPct == null && nullToAbsent
          ? const Value.absent()
          : Value(summaryPct),
      prevSessionId: prevSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(prevSessionId),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      day: serializer.fromJson<int>(json['day']),
      programId: serializer.fromJson<int>(json['programId']),
      timeIn: serializer.fromJson<int?>(json['timeIn']),
      timeOut: serializer.fromJson<int?>(json['timeOut']),
      volume: serializer.fromJson<int>(json['volume']),
      setCount: serializer.fromJson<int>(json['setCount']),
      summaryPct: serializer.fromJson<int?>(json['summaryPct']),
      prevSessionId: serializer.fromJson<int?>(json['prevSessionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'day': serializer.toJson<int>(day),
      'programId': serializer.toJson<int>(programId),
      'timeIn': serializer.toJson<int?>(timeIn),
      'timeOut': serializer.toJson<int?>(timeOut),
      'volume': serializer.toJson<int>(volume),
      'setCount': serializer.toJson<int>(setCount),
      'summaryPct': serializer.toJson<int?>(summaryPct),
      'prevSessionId': serializer.toJson<int?>(prevSessionId),
    };
  }

  Session copyWith({
    int? id,
    int? day,
    int? programId,
    Value<int?> timeIn = const Value.absent(),
    Value<int?> timeOut = const Value.absent(),
    int? volume,
    int? setCount,
    Value<int?> summaryPct = const Value.absent(),
    Value<int?> prevSessionId = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    day: day ?? this.day,
    programId: programId ?? this.programId,
    timeIn: timeIn.present ? timeIn.value : this.timeIn,
    timeOut: timeOut.present ? timeOut.value : this.timeOut,
    volume: volume ?? this.volume,
    setCount: setCount ?? this.setCount,
    summaryPct: summaryPct.present ? summaryPct.value : this.summaryPct,
    prevSessionId: prevSessionId.present
        ? prevSessionId.value
        : this.prevSessionId,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      programId: data.programId.present ? data.programId.value : this.programId,
      timeIn: data.timeIn.present ? data.timeIn.value : this.timeIn,
      timeOut: data.timeOut.present ? data.timeOut.value : this.timeOut,
      volume: data.volume.present ? data.volume.value : this.volume,
      setCount: data.setCount.present ? data.setCount.value : this.setCount,
      summaryPct: data.summaryPct.present
          ? data.summaryPct.value
          : this.summaryPct,
      prevSessionId: data.prevSessionId.present
          ? data.prevSessionId.value
          : this.prevSessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('programId: $programId, ')
          ..write('timeIn: $timeIn, ')
          ..write('timeOut: $timeOut, ')
          ..write('volume: $volume, ')
          ..write('setCount: $setCount, ')
          ..write('summaryPct: $summaryPct, ')
          ..write('prevSessionId: $prevSessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    day,
    programId,
    timeIn,
    timeOut,
    volume,
    setCount,
    summaryPct,
    prevSessionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.day == this.day &&
          other.programId == this.programId &&
          other.timeIn == this.timeIn &&
          other.timeOut == this.timeOut &&
          other.volume == this.volume &&
          other.setCount == this.setCount &&
          other.summaryPct == this.summaryPct &&
          other.prevSessionId == this.prevSessionId);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<int> day;
  final Value<int> programId;
  final Value<int?> timeIn;
  final Value<int?> timeOut;
  final Value<int> volume;
  final Value<int> setCount;
  final Value<int?> summaryPct;
  final Value<int?> prevSessionId;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.programId = const Value.absent(),
    this.timeIn = const Value.absent(),
    this.timeOut = const Value.absent(),
    this.volume = const Value.absent(),
    this.setCount = const Value.absent(),
    this.summaryPct = const Value.absent(),
    this.prevSessionId = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required int day,
    required int programId,
    this.timeIn = const Value.absent(),
    this.timeOut = const Value.absent(),
    this.volume = const Value.absent(),
    this.setCount = const Value.absent(),
    this.summaryPct = const Value.absent(),
    this.prevSessionId = const Value.absent(),
  }) : day = Value(day),
       programId = Value(programId);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<int>? day,
    Expression<int>? programId,
    Expression<int>? timeIn,
    Expression<int>? timeOut,
    Expression<int>? volume,
    Expression<int>? setCount,
    Expression<int>? summaryPct,
    Expression<int>? prevSessionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (programId != null) 'program_id': programId,
      if (timeIn != null) 'time_in': timeIn,
      if (timeOut != null) 'time_out': timeOut,
      if (volume != null) 'volume': volume,
      if (setCount != null) 'set_count': setCount,
      if (summaryPct != null) 'summary_pct': summaryPct,
      if (prevSessionId != null) 'prev_session_id': prevSessionId,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? day,
    Value<int>? programId,
    Value<int?>? timeIn,
    Value<int?>? timeOut,
    Value<int>? volume,
    Value<int>? setCount,
    Value<int?>? summaryPct,
    Value<int?>? prevSessionId,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      programId: programId ?? this.programId,
      timeIn: timeIn ?? this.timeIn,
      timeOut: timeOut ?? this.timeOut,
      volume: volume ?? this.volume,
      setCount: setCount ?? this.setCount,
      summaryPct: summaryPct ?? this.summaryPct,
      prevSessionId: prevSessionId ?? this.prevSessionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<int>(programId.value);
    }
    if (timeIn.present) {
      map['time_in'] = Variable<int>(timeIn.value);
    }
    if (timeOut.present) {
      map['time_out'] = Variable<int>(timeOut.value);
    }
    if (volume.present) {
      map['volume'] = Variable<int>(volume.value);
    }
    if (setCount.present) {
      map['set_count'] = Variable<int>(setCount.value);
    }
    if (summaryPct.present) {
      map['summary_pct'] = Variable<int>(summaryPct.value);
    }
    if (prevSessionId.present) {
      map['prev_session_id'] = Variable<int>(prevSessionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('programId: $programId, ')
          ..write('timeIn: $timeIn, ')
          ..write('timeOut: $timeOut, ')
          ..write('volume: $volume, ')
          ..write('setCount: $setCount, ')
          ..write('summaryPct: $summaryPct, ')
          ..write('prevSessionId: $prevSessionId')
          ..write(')'))
        .toString();
  }
}

class $ExerciseLogsTable extends ExerciseLogs
    with TableInfo<$ExerciseLogsTable, ExerciseLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<int> volume = GeneratedColumn<int>(
    'volume',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _setCountMeta = const VerificationMeta(
    'setCount',
  );
  @override
  late final GeneratedColumn<int> setCount = GeneratedColumn<int>(
    'set_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestWeightMeta = const VerificationMeta(
    'bestWeight',
  );
  @override
  late final GeneratedColumn<int> bestWeight = GeneratedColumn<int>(
    'best_weight',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsAtTopMeta = const VerificationMeta(
    'repsAtTop',
  );
  @override
  late final GeneratedColumn<int> repsAtTop = GeneratedColumn<int>(
    'reps_at_top',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pctMeta = const VerificationMeta('pct');
  @override
  late final GeneratedColumn<int> pct = GeneratedColumn<int>(
    'pct',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prevLogIdMeta = const VerificationMeta(
    'prevLogId',
  );
  @override
  late final GeneratedColumn<int> prevLogId = GeneratedColumn<int>(
    'prev_log_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise_logs (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    exerciseId,
    day,
    sortOrder,
    volume,
    setCount,
    bestWeight,
    repsAtTop,
    pct,
    prevLogId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('volume')) {
      context.handle(
        _volumeMeta,
        volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta),
      );
    }
    if (data.containsKey('set_count')) {
      context.handle(
        _setCountMeta,
        setCount.isAcceptableOrUnknown(data['set_count']!, _setCountMeta),
      );
    }
    if (data.containsKey('best_weight')) {
      context.handle(
        _bestWeightMeta,
        bestWeight.isAcceptableOrUnknown(data['best_weight']!, _bestWeightMeta),
      );
    }
    if (data.containsKey('reps_at_top')) {
      context.handle(
        _repsAtTopMeta,
        repsAtTop.isAcceptableOrUnknown(data['reps_at_top']!, _repsAtTopMeta),
      );
    }
    if (data.containsKey('pct')) {
      context.handle(
        _pctMeta,
        pct.isAcceptableOrUnknown(data['pct']!, _pctMeta),
      );
    }
    if (data.containsKey('prev_log_id')) {
      context.handle(
        _prevLogIdMeta,
        prevLogId.isAcceptableOrUnknown(data['prev_log_id']!, _prevLogIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId, exerciseId},
  ];
  @override
  ExerciseLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      volume: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}volume'],
      )!,
      setCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_count'],
      )!,
      bestWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_weight'],
      ),
      repsAtTop: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps_at_top'],
      )!,
      pct: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pct'],
      ),
      prevLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prev_log_id'],
      ),
    );
  }

  @override
  $ExerciseLogsTable createAlias(String alias) {
    return $ExerciseLogsTable(attachedDatabase, alias);
  }
}

class ExerciseLog extends DataClass implements Insertable<ExerciseLog> {
  final int id;
  final int sessionId;
  final int exerciseId;

  /// Copy of the session's day, so exercise history is one indexed lookup.
  final int day;
  final int sortOrder;
  final int volume;
  final int setCount;
  final int? bestWeight;

  /// Most reps in one set at [bestWeight]. Used for personal-best detection.
  final int repsAtTop;
  final int? pct;
  final int? prevLogId;
  const ExerciseLog({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.day,
    required this.sortOrder,
    required this.volume,
    required this.setCount,
    this.bestWeight,
    required this.repsAtTop,
    this.pct,
    this.prevLogId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['day'] = Variable<int>(day);
    map['sort_order'] = Variable<int>(sortOrder);
    map['volume'] = Variable<int>(volume);
    map['set_count'] = Variable<int>(setCount);
    if (!nullToAbsent || bestWeight != null) {
      map['best_weight'] = Variable<int>(bestWeight);
    }
    map['reps_at_top'] = Variable<int>(repsAtTop);
    if (!nullToAbsent || pct != null) {
      map['pct'] = Variable<int>(pct);
    }
    if (!nullToAbsent || prevLogId != null) {
      map['prev_log_id'] = Variable<int>(prevLogId);
    }
    return map;
  }

  ExerciseLogsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseLogsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      day: Value(day),
      sortOrder: Value(sortOrder),
      volume: Value(volume),
      setCount: Value(setCount),
      bestWeight: bestWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(bestWeight),
      repsAtTop: Value(repsAtTop),
      pct: pct == null && nullToAbsent ? const Value.absent() : Value(pct),
      prevLogId: prevLogId == null && nullToAbsent
          ? const Value.absent()
          : Value(prevLogId),
    );
  }

  factory ExerciseLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseLog(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      day: serializer.fromJson<int>(json['day']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      volume: serializer.fromJson<int>(json['volume']),
      setCount: serializer.fromJson<int>(json['setCount']),
      bestWeight: serializer.fromJson<int?>(json['bestWeight']),
      repsAtTop: serializer.fromJson<int>(json['repsAtTop']),
      pct: serializer.fromJson<int?>(json['pct']),
      prevLogId: serializer.fromJson<int?>(json['prevLogId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'day': serializer.toJson<int>(day),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'volume': serializer.toJson<int>(volume),
      'setCount': serializer.toJson<int>(setCount),
      'bestWeight': serializer.toJson<int?>(bestWeight),
      'repsAtTop': serializer.toJson<int>(repsAtTop),
      'pct': serializer.toJson<int?>(pct),
      'prevLogId': serializer.toJson<int?>(prevLogId),
    };
  }

  ExerciseLog copyWith({
    int? id,
    int? sessionId,
    int? exerciseId,
    int? day,
    int? sortOrder,
    int? volume,
    int? setCount,
    Value<int?> bestWeight = const Value.absent(),
    int? repsAtTop,
    Value<int?> pct = const Value.absent(),
    Value<int?> prevLogId = const Value.absent(),
  }) => ExerciseLog(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId ?? this.exerciseId,
    day: day ?? this.day,
    sortOrder: sortOrder ?? this.sortOrder,
    volume: volume ?? this.volume,
    setCount: setCount ?? this.setCount,
    bestWeight: bestWeight.present ? bestWeight.value : this.bestWeight,
    repsAtTop: repsAtTop ?? this.repsAtTop,
    pct: pct.present ? pct.value : this.pct,
    prevLogId: prevLogId.present ? prevLogId.value : this.prevLogId,
  );
  ExerciseLog copyWithCompanion(ExerciseLogsCompanion data) {
    return ExerciseLog(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      day: data.day.present ? data.day.value : this.day,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      volume: data.volume.present ? data.volume.value : this.volume,
      setCount: data.setCount.present ? data.setCount.value : this.setCount,
      bestWeight: data.bestWeight.present
          ? data.bestWeight.value
          : this.bestWeight,
      repsAtTop: data.repsAtTop.present ? data.repsAtTop.value : this.repsAtTop,
      pct: data.pct.present ? data.pct.value : this.pct,
      prevLogId: data.prevLogId.present ? data.prevLogId.value : this.prevLogId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseLog(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('day: $day, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('volume: $volume, ')
          ..write('setCount: $setCount, ')
          ..write('bestWeight: $bestWeight, ')
          ..write('repsAtTop: $repsAtTop, ')
          ..write('pct: $pct, ')
          ..write('prevLogId: $prevLogId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    exerciseId,
    day,
    sortOrder,
    volume,
    setCount,
    bestWeight,
    repsAtTop,
    pct,
    prevLogId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseLog &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.day == this.day &&
          other.sortOrder == this.sortOrder &&
          other.volume == this.volume &&
          other.setCount == this.setCount &&
          other.bestWeight == this.bestWeight &&
          other.repsAtTop == this.repsAtTop &&
          other.pct == this.pct &&
          other.prevLogId == this.prevLogId);
}

class ExerciseLogsCompanion extends UpdateCompanion<ExerciseLog> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> exerciseId;
  final Value<int> day;
  final Value<int> sortOrder;
  final Value<int> volume;
  final Value<int> setCount;
  final Value<int?> bestWeight;
  final Value<int> repsAtTop;
  final Value<int?> pct;
  final Value<int?> prevLogId;
  const ExerciseLogsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.day = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.volume = const Value.absent(),
    this.setCount = const Value.absent(),
    this.bestWeight = const Value.absent(),
    this.repsAtTop = const Value.absent(),
    this.pct = const Value.absent(),
    this.prevLogId = const Value.absent(),
  });
  ExerciseLogsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int exerciseId,
    required int day,
    this.sortOrder = const Value.absent(),
    this.volume = const Value.absent(),
    this.setCount = const Value.absent(),
    this.bestWeight = const Value.absent(),
    this.repsAtTop = const Value.absent(),
    this.pct = const Value.absent(),
    this.prevLogId = const Value.absent(),
  }) : sessionId = Value(sessionId),
       exerciseId = Value(exerciseId),
       day = Value(day);
  static Insertable<ExerciseLog> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? exerciseId,
    Expression<int>? day,
    Expression<int>? sortOrder,
    Expression<int>? volume,
    Expression<int>? setCount,
    Expression<int>? bestWeight,
    Expression<int>? repsAtTop,
    Expression<int>? pct,
    Expression<int>? prevLogId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (day != null) 'day': day,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (volume != null) 'volume': volume,
      if (setCount != null) 'set_count': setCount,
      if (bestWeight != null) 'best_weight': bestWeight,
      if (repsAtTop != null) 'reps_at_top': repsAtTop,
      if (pct != null) 'pct': pct,
      if (prevLogId != null) 'prev_log_id': prevLogId,
    });
  }

  ExerciseLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? exerciseId,
    Value<int>? day,
    Value<int>? sortOrder,
    Value<int>? volume,
    Value<int>? setCount,
    Value<int?>? bestWeight,
    Value<int>? repsAtTop,
    Value<int?>? pct,
    Value<int?>? prevLogId,
  }) {
    return ExerciseLogsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      day: day ?? this.day,
      sortOrder: sortOrder ?? this.sortOrder,
      volume: volume ?? this.volume,
      setCount: setCount ?? this.setCount,
      bestWeight: bestWeight ?? this.bestWeight,
      repsAtTop: repsAtTop ?? this.repsAtTop,
      pct: pct ?? this.pct,
      prevLogId: prevLogId ?? this.prevLogId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (volume.present) {
      map['volume'] = Variable<int>(volume.value);
    }
    if (setCount.present) {
      map['set_count'] = Variable<int>(setCount.value);
    }
    if (bestWeight.present) {
      map['best_weight'] = Variable<int>(bestWeight.value);
    }
    if (repsAtTop.present) {
      map['reps_at_top'] = Variable<int>(repsAtTop.value);
    }
    if (pct.present) {
      map['pct'] = Variable<int>(pct.value);
    }
    if (prevLogId.present) {
      map['prev_log_id'] = Variable<int>(prevLogId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseLogsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('day: $day, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('volume: $volume, ')
          ..write('setCount: $setCount, ')
          ..write('bestWeight: $bestWeight, ')
          ..write('repsAtTop: $repsAtTop, ')
          ..write('pct: $pct, ')
          ..write('prevLogId: $prevLogId')
          ..write(')'))
        .toString();
  }
}

class $SetEntriesTable extends SetEntries
    with TableInfo<$SetEntriesTable, SetEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _exerciseLogIdMeta = const VerificationMeta(
    'exerciseLogId',
  );
  @override
  late final GeneratedColumn<int> exerciseLogId = GeneratedColumn<int>(
    'exercise_log_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise_logs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _idxMeta = const VerificationMeta('idx');
  @override
  late final GeneratedColumn<int> idx = GeneratedColumn<int>(
    'idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<int> weight = GeneratedColumn<int>(
    'weight',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, exerciseLogId, idx, weight, reps];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'set_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SetEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exercise_log_id')) {
      context.handle(
        _exerciseLogIdMeta,
        exerciseLogId.isAcceptableOrUnknown(
          data['exercise_log_id']!,
          _exerciseLogIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseLogIdMeta);
    }
    if (data.containsKey('idx')) {
      context.handle(
        _idxMeta,
        idx.isAcceptableOrUnknown(data['idx']!, _idxMeta),
      );
    } else if (isInserting) {
      context.missing(_idxMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {exerciseLogId, idx},
  ];
  @override
  SetEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      exerciseLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_log_id'],
      )!,
      idx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}idx'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight'],
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
    );
  }

  @override
  $SetEntriesTable createAlias(String alias) {
    return $SetEntriesTable(attachedDatabase, alias);
  }
}

class SetEntry extends DataClass implements Insertable<SetEntry> {
  final int id;
  final int exerciseLogId;

  /// 1-based position within the exercise; shown as "1.", "2.", ...
  final int idx;

  /// Null for pure bodyweight sets and for timed and sport exercises. For
  /// "BW + 10 kg" this holds the added weight.
  final int? weight;

  /// Repetitions, or for timed and sport exercises the duration in seconds.
  final int reps;
  const SetEntry({
    required this.id,
    required this.exerciseLogId,
    required this.idx,
    this.weight,
    required this.reps,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_log_id'] = Variable<int>(exerciseLogId);
    map['idx'] = Variable<int>(idx);
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<int>(weight);
    }
    map['reps'] = Variable<int>(reps);
    return map;
  }

  SetEntriesCompanion toCompanion(bool nullToAbsent) {
    return SetEntriesCompanion(
      id: Value(id),
      exerciseLogId: Value(exerciseLogId),
      idx: Value(idx),
      weight: weight == null && nullToAbsent
          ? const Value.absent()
          : Value(weight),
      reps: Value(reps),
    );
  }

  factory SetEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetEntry(
      id: serializer.fromJson<int>(json['id']),
      exerciseLogId: serializer.fromJson<int>(json['exerciseLogId']),
      idx: serializer.fromJson<int>(json['idx']),
      weight: serializer.fromJson<int?>(json['weight']),
      reps: serializer.fromJson<int>(json['reps']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseLogId': serializer.toJson<int>(exerciseLogId),
      'idx': serializer.toJson<int>(idx),
      'weight': serializer.toJson<int?>(weight),
      'reps': serializer.toJson<int>(reps),
    };
  }

  SetEntry copyWith({
    int? id,
    int? exerciseLogId,
    int? idx,
    Value<int?> weight = const Value.absent(),
    int? reps,
  }) => SetEntry(
    id: id ?? this.id,
    exerciseLogId: exerciseLogId ?? this.exerciseLogId,
    idx: idx ?? this.idx,
    weight: weight.present ? weight.value : this.weight,
    reps: reps ?? this.reps,
  );
  SetEntry copyWithCompanion(SetEntriesCompanion data) {
    return SetEntry(
      id: data.id.present ? data.id.value : this.id,
      exerciseLogId: data.exerciseLogId.present
          ? data.exerciseLogId.value
          : this.exerciseLogId,
      idx: data.idx.present ? data.idx.value : this.idx,
      weight: data.weight.present ? data.weight.value : this.weight,
      reps: data.reps.present ? data.reps.value : this.reps,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetEntry(')
          ..write('id: $id, ')
          ..write('exerciseLogId: $exerciseLogId, ')
          ..write('idx: $idx, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, exerciseLogId, idx, weight, reps);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetEntry &&
          other.id == this.id &&
          other.exerciseLogId == this.exerciseLogId &&
          other.idx == this.idx &&
          other.weight == this.weight &&
          other.reps == this.reps);
}

class SetEntriesCompanion extends UpdateCompanion<SetEntry> {
  final Value<int> id;
  final Value<int> exerciseLogId;
  final Value<int> idx;
  final Value<int?> weight;
  final Value<int> reps;
  const SetEntriesCompanion({
    this.id = const Value.absent(),
    this.exerciseLogId = const Value.absent(),
    this.idx = const Value.absent(),
    this.weight = const Value.absent(),
    this.reps = const Value.absent(),
  });
  SetEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int exerciseLogId,
    required int idx,
    this.weight = const Value.absent(),
    required int reps,
  }) : exerciseLogId = Value(exerciseLogId),
       idx = Value(idx),
       reps = Value(reps);
  static Insertable<SetEntry> custom({
    Expression<int>? id,
    Expression<int>? exerciseLogId,
    Expression<int>? idx,
    Expression<int>? weight,
    Expression<int>? reps,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseLogId != null) 'exercise_log_id': exerciseLogId,
      if (idx != null) 'idx': idx,
      if (weight != null) 'weight': weight,
      if (reps != null) 'reps': reps,
    });
  }

  SetEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? exerciseLogId,
    Value<int>? idx,
    Value<int?>? weight,
    Value<int>? reps,
  }) {
    return SetEntriesCompanion(
      id: id ?? this.id,
      exerciseLogId: exerciseLogId ?? this.exerciseLogId,
      idx: idx ?? this.idx,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseLogId.present) {
      map['exercise_log_id'] = Variable<int>(exerciseLogId.value);
    }
    if (idx.present) {
      map['idx'] = Variable<int>(idx.value);
    }
    if (weight.present) {
      map['weight'] = Variable<int>(weight.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetEntriesCompanion(')
          ..write('id: $id, ')
          ..write('exerciseLogId: $exerciseLogId, ')
          ..write('idx: $idx, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps')
          ..write(')'))
        .toString();
  }
}

class $DaySummariesTable extends DaySummaries
    with TableInfo<$DaySummariesTable, DaySummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DaySummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _setCountMeta = const VerificationMeta(
    'setCount',
  );
  @override
  late final GeneratedColumn<int> setCount = GeneratedColumn<int>(
    'set_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isRestMeta = const VerificationMeta('isRest');
  @override
  late final GeneratedColumn<bool> isRest = GeneratedColumn<bool>(
    'is_rest',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_rest" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [day, sessionId, setCount, isRest];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DaySummary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('set_count')) {
      context.handle(
        _setCountMeta,
        setCount.isAcceptableOrUnknown(data['set_count']!, _setCountMeta),
      );
    }
    if (data.containsKey('is_rest')) {
      context.handle(
        _isRestMeta,
        isRest.isAcceptableOrUnknown(data['is_rest']!, _isRestMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  DaySummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DaySummary(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
      setCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_count'],
      )!,
      isRest: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_rest'],
      )!,
    );
  }

  @override
  $DaySummariesTable createAlias(String alias) {
    return $DaySummariesTable(attachedDatabase, alias);
  }
}

class DaySummary extends DataClass implements Insertable<DaySummary> {
  final int day;
  final int? sessionId;
  final int setCount;
  final bool isRest;
  const DaySummary({
    required this.day,
    this.sessionId,
    required this.setCount,
    required this.isRest,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<int>(day);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    map['set_count'] = Variable<int>(setCount);
    map['is_rest'] = Variable<bool>(isRest);
    return map;
  }

  DaySummariesCompanion toCompanion(bool nullToAbsent) {
    return DaySummariesCompanion(
      day: Value(day),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      setCount: Value(setCount),
      isRest: Value(isRest),
    );
  }

  factory DaySummary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DaySummary(
      day: serializer.fromJson<int>(json['day']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      setCount: serializer.fromJson<int>(json['setCount']),
      isRest: serializer.fromJson<bool>(json['isRest']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<int>(day),
      'sessionId': serializer.toJson<int?>(sessionId),
      'setCount': serializer.toJson<int>(setCount),
      'isRest': serializer.toJson<bool>(isRest),
    };
  }

  DaySummary copyWith({
    int? day,
    Value<int?> sessionId = const Value.absent(),
    int? setCount,
    bool? isRest,
  }) => DaySummary(
    day: day ?? this.day,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    setCount: setCount ?? this.setCount,
    isRest: isRest ?? this.isRest,
  );
  DaySummary copyWithCompanion(DaySummariesCompanion data) {
    return DaySummary(
      day: data.day.present ? data.day.value : this.day,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      setCount: data.setCount.present ? data.setCount.value : this.setCount,
      isRest: data.isRest.present ? data.isRest.value : this.isRest,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DaySummary(')
          ..write('day: $day, ')
          ..write('sessionId: $sessionId, ')
          ..write('setCount: $setCount, ')
          ..write('isRest: $isRest')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, sessionId, setCount, isRest);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DaySummary &&
          other.day == this.day &&
          other.sessionId == this.sessionId &&
          other.setCount == this.setCount &&
          other.isRest == this.isRest);
}

class DaySummariesCompanion extends UpdateCompanion<DaySummary> {
  final Value<int> day;
  final Value<int?> sessionId;
  final Value<int> setCount;
  final Value<bool> isRest;
  const DaySummariesCompanion({
    this.day = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.setCount = const Value.absent(),
    this.isRest = const Value.absent(),
  });
  DaySummariesCompanion.insert({
    this.day = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.setCount = const Value.absent(),
    this.isRest = const Value.absent(),
  });
  static Insertable<DaySummary> custom({
    Expression<int>? day,
    Expression<int>? sessionId,
    Expression<int>? setCount,
    Expression<bool>? isRest,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (sessionId != null) 'session_id': sessionId,
      if (setCount != null) 'set_count': setCount,
      if (isRest != null) 'is_rest': isRest,
    });
  }

  DaySummariesCompanion copyWith({
    Value<int>? day,
    Value<int?>? sessionId,
    Value<int>? setCount,
    Value<bool>? isRest,
  }) {
    return DaySummariesCompanion(
      day: day ?? this.day,
      sessionId: sessionId ?? this.sessionId,
      setCount: setCount ?? this.setCount,
      isRest: isRest ?? this.isRest,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (setCount.present) {
      map['set_count'] = Variable<int>(setCount.value);
    }
    if (isRest.present) {
      map['is_rest'] = Variable<bool>(isRest.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DaySummariesCompanion(')
          ..write('day: $day, ')
          ..write('sessionId: $sessionId, ')
          ..write('setCount: $setCount, ')
          ..write('isRest: $isRest')
          ..write(')'))
        .toString();
  }
}

class $WeekSummariesTable extends WeekSummaries
    with TableInfo<$WeekSummariesTable, WeekSummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeekSummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<int> weekStart = GeneratedColumn<int>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionCountMeta = const VerificationMeta(
    'sessionCount',
  );
  @override
  late final GeneratedColumn<int> sessionCount = GeneratedColumn<int>(
    'session_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [weekStart, sessionCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'week_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeekSummary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    }
    if (data.containsKey('session_count')) {
      context.handle(
        _sessionCountMeta,
        sessionCount.isAcceptableOrUnknown(
          data['session_count']!,
          _sessionCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {weekStart};
  @override
  WeekSummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeekSummary(
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_start'],
      )!,
      sessionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_count'],
      )!,
    );
  }

  @override
  $WeekSummariesTable createAlias(String alias) {
    return $WeekSummariesTable(attachedDatabase, alias);
  }
}

class WeekSummary extends DataClass implements Insertable<WeekSummary> {
  /// Epoch-day of the Monday that starts the week.
  final int weekStart;
  final int sessionCount;
  const WeekSummary({required this.weekStart, required this.sessionCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['week_start'] = Variable<int>(weekStart);
    map['session_count'] = Variable<int>(sessionCount);
    return map;
  }

  WeekSummariesCompanion toCompanion(bool nullToAbsent) {
    return WeekSummariesCompanion(
      weekStart: Value(weekStart),
      sessionCount: Value(sessionCount),
    );
  }

  factory WeekSummary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeekSummary(
      weekStart: serializer.fromJson<int>(json['weekStart']),
      sessionCount: serializer.fromJson<int>(json['sessionCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'weekStart': serializer.toJson<int>(weekStart),
      'sessionCount': serializer.toJson<int>(sessionCount),
    };
  }

  WeekSummary copyWith({int? weekStart, int? sessionCount}) => WeekSummary(
    weekStart: weekStart ?? this.weekStart,
    sessionCount: sessionCount ?? this.sessionCount,
  );
  WeekSummary copyWithCompanion(WeekSummariesCompanion data) {
    return WeekSummary(
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      sessionCount: data.sessionCount.present
          ? data.sessionCount.value
          : this.sessionCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeekSummary(')
          ..write('weekStart: $weekStart, ')
          ..write('sessionCount: $sessionCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(weekStart, sessionCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeekSummary &&
          other.weekStart == this.weekStart &&
          other.sessionCount == this.sessionCount);
}

class WeekSummariesCompanion extends UpdateCompanion<WeekSummary> {
  final Value<int> weekStart;
  final Value<int> sessionCount;
  const WeekSummariesCompanion({
    this.weekStart = const Value.absent(),
    this.sessionCount = const Value.absent(),
  });
  WeekSummariesCompanion.insert({
    this.weekStart = const Value.absent(),
    this.sessionCount = const Value.absent(),
  });
  static Insertable<WeekSummary> custom({
    Expression<int>? weekStart,
    Expression<int>? sessionCount,
  }) {
    return RawValuesInsertable({
      if (weekStart != null) 'week_start': weekStart,
      if (sessionCount != null) 'session_count': sessionCount,
    });
  }

  WeekSummariesCompanion copyWith({
    Value<int>? weekStart,
    Value<int>? sessionCount,
  }) {
    return WeekSummariesCompanion(
      weekStart: weekStart ?? this.weekStart,
      sessionCount: sessionCount ?? this.sessionCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (weekStart.present) {
      map['week_start'] = Variable<int>(weekStart.value);
    }
    if (sessionCount.present) {
      map['session_count'] = Variable<int>(sessionCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeekSummariesCompanion(')
          ..write('weekStart: $weekStart, ')
          ..write('sessionCount: $sessionCount')
          ..write(')'))
        .toString();
  }
}

class $ExerciseStatsTable extends ExerciseStats
    with TableInfo<$ExerciseStatsTable, ExerciseStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _bestWeightMeta = const VerificationMeta(
    'bestWeight',
  );
  @override
  late final GeneratedColumn<int> bestWeight = GeneratedColumn<int>(
    'best_weight',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bestRepsAtWeightMeta = const VerificationMeta(
    'bestRepsAtWeight',
  );
  @override
  late final GeneratedColumn<int> bestRepsAtWeight = GeneratedColumn<int>(
    'best_reps_at_weight',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bestVolumeMeta = const VerificationMeta(
    'bestVolume',
  );
  @override
  late final GeneratedColumn<int> bestVolume = GeneratedColumn<int>(
    'best_volume',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastLogIdMeta = const VerificationMeta(
    'lastLogId',
  );
  @override
  late final GeneratedColumn<int> lastLogId = GeneratedColumn<int>(
    'last_log_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise_logs (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    exerciseId,
    bestWeight,
    bestRepsAtWeight,
    bestVolume,
    lastLogId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseStat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    }
    if (data.containsKey('best_weight')) {
      context.handle(
        _bestWeightMeta,
        bestWeight.isAcceptableOrUnknown(data['best_weight']!, _bestWeightMeta),
      );
    }
    if (data.containsKey('best_reps_at_weight')) {
      context.handle(
        _bestRepsAtWeightMeta,
        bestRepsAtWeight.isAcceptableOrUnknown(
          data['best_reps_at_weight']!,
          _bestRepsAtWeightMeta,
        ),
      );
    }
    if (data.containsKey('best_volume')) {
      context.handle(
        _bestVolumeMeta,
        bestVolume.isAcceptableOrUnknown(data['best_volume']!, _bestVolumeMeta),
      );
    }
    if (data.containsKey('last_log_id')) {
      context.handle(
        _lastLogIdMeta,
        lastLogId.isAcceptableOrUnknown(data['last_log_id']!, _lastLogIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId};
  @override
  ExerciseStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseStat(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      bestWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_weight'],
      ),
      bestRepsAtWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_reps_at_weight'],
      ),
      bestVolume: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_volume'],
      )!,
      lastLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_log_id'],
      ),
    );
  }

  @override
  $ExerciseStatsTable createAlias(String alias) {
    return $ExerciseStatsTable(attachedDatabase, alias);
  }
}

class ExerciseStat extends DataClass implements Insertable<ExerciseStat> {
  final int exerciseId;
  final int? bestWeight;
  final int? bestRepsAtWeight;
  final int bestVolume;
  final int? lastLogId;
  const ExerciseStat({
    required this.exerciseId,
    this.bestWeight,
    this.bestRepsAtWeight,
    required this.bestVolume,
    this.lastLogId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<int>(exerciseId);
    if (!nullToAbsent || bestWeight != null) {
      map['best_weight'] = Variable<int>(bestWeight);
    }
    if (!nullToAbsent || bestRepsAtWeight != null) {
      map['best_reps_at_weight'] = Variable<int>(bestRepsAtWeight);
    }
    map['best_volume'] = Variable<int>(bestVolume);
    if (!nullToAbsent || lastLogId != null) {
      map['last_log_id'] = Variable<int>(lastLogId);
    }
    return map;
  }

  ExerciseStatsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseStatsCompanion(
      exerciseId: Value(exerciseId),
      bestWeight: bestWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(bestWeight),
      bestRepsAtWeight: bestRepsAtWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(bestRepsAtWeight),
      bestVolume: Value(bestVolume),
      lastLogId: lastLogId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLogId),
    );
  }

  factory ExerciseStat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseStat(
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      bestWeight: serializer.fromJson<int?>(json['bestWeight']),
      bestRepsAtWeight: serializer.fromJson<int?>(json['bestRepsAtWeight']),
      bestVolume: serializer.fromJson<int>(json['bestVolume']),
      lastLogId: serializer.fromJson<int?>(json['lastLogId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<int>(exerciseId),
      'bestWeight': serializer.toJson<int?>(bestWeight),
      'bestRepsAtWeight': serializer.toJson<int?>(bestRepsAtWeight),
      'bestVolume': serializer.toJson<int>(bestVolume),
      'lastLogId': serializer.toJson<int?>(lastLogId),
    };
  }

  ExerciseStat copyWith({
    int? exerciseId,
    Value<int?> bestWeight = const Value.absent(),
    Value<int?> bestRepsAtWeight = const Value.absent(),
    int? bestVolume,
    Value<int?> lastLogId = const Value.absent(),
  }) => ExerciseStat(
    exerciseId: exerciseId ?? this.exerciseId,
    bestWeight: bestWeight.present ? bestWeight.value : this.bestWeight,
    bestRepsAtWeight: bestRepsAtWeight.present
        ? bestRepsAtWeight.value
        : this.bestRepsAtWeight,
    bestVolume: bestVolume ?? this.bestVolume,
    lastLogId: lastLogId.present ? lastLogId.value : this.lastLogId,
  );
  ExerciseStat copyWithCompanion(ExerciseStatsCompanion data) {
    return ExerciseStat(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      bestWeight: data.bestWeight.present
          ? data.bestWeight.value
          : this.bestWeight,
      bestRepsAtWeight: data.bestRepsAtWeight.present
          ? data.bestRepsAtWeight.value
          : this.bestRepsAtWeight,
      bestVolume: data.bestVolume.present
          ? data.bestVolume.value
          : this.bestVolume,
      lastLogId: data.lastLogId.present ? data.lastLogId.value : this.lastLogId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseStat(')
          ..write('exerciseId: $exerciseId, ')
          ..write('bestWeight: $bestWeight, ')
          ..write('bestRepsAtWeight: $bestRepsAtWeight, ')
          ..write('bestVolume: $bestVolume, ')
          ..write('lastLogId: $lastLogId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    exerciseId,
    bestWeight,
    bestRepsAtWeight,
    bestVolume,
    lastLogId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseStat &&
          other.exerciseId == this.exerciseId &&
          other.bestWeight == this.bestWeight &&
          other.bestRepsAtWeight == this.bestRepsAtWeight &&
          other.bestVolume == this.bestVolume &&
          other.lastLogId == this.lastLogId);
}

class ExerciseStatsCompanion extends UpdateCompanion<ExerciseStat> {
  final Value<int> exerciseId;
  final Value<int?> bestWeight;
  final Value<int?> bestRepsAtWeight;
  final Value<int> bestVolume;
  final Value<int?> lastLogId;
  const ExerciseStatsCompanion({
    this.exerciseId = const Value.absent(),
    this.bestWeight = const Value.absent(),
    this.bestRepsAtWeight = const Value.absent(),
    this.bestVolume = const Value.absent(),
    this.lastLogId = const Value.absent(),
  });
  ExerciseStatsCompanion.insert({
    this.exerciseId = const Value.absent(),
    this.bestWeight = const Value.absent(),
    this.bestRepsAtWeight = const Value.absent(),
    this.bestVolume = const Value.absent(),
    this.lastLogId = const Value.absent(),
  });
  static Insertable<ExerciseStat> custom({
    Expression<int>? exerciseId,
    Expression<int>? bestWeight,
    Expression<int>? bestRepsAtWeight,
    Expression<int>? bestVolume,
    Expression<int>? lastLogId,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (bestWeight != null) 'best_weight': bestWeight,
      if (bestRepsAtWeight != null) 'best_reps_at_weight': bestRepsAtWeight,
      if (bestVolume != null) 'best_volume': bestVolume,
      if (lastLogId != null) 'last_log_id': lastLogId,
    });
  }

  ExerciseStatsCompanion copyWith({
    Value<int>? exerciseId,
    Value<int?>? bestWeight,
    Value<int?>? bestRepsAtWeight,
    Value<int>? bestVolume,
    Value<int?>? lastLogId,
  }) {
    return ExerciseStatsCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      bestWeight: bestWeight ?? this.bestWeight,
      bestRepsAtWeight: bestRepsAtWeight ?? this.bestRepsAtWeight,
      bestVolume: bestVolume ?? this.bestVolume,
      lastLogId: lastLogId ?? this.lastLogId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (bestWeight.present) {
      map['best_weight'] = Variable<int>(bestWeight.value);
    }
    if (bestRepsAtWeight.present) {
      map['best_reps_at_weight'] = Variable<int>(bestRepsAtWeight.value);
    }
    if (bestVolume.present) {
      map['best_volume'] = Variable<int>(bestVolume.value);
    }
    if (lastLogId.present) {
      map['last_log_id'] = Variable<int>(lastLogId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseStatsCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('bestWeight: $bestWeight, ')
          ..write('bestRepsAtWeight: $bestRepsAtWeight, ')
          ..write('bestVolume: $bestVolume, ')
          ..write('lastLogId: $lastLogId')
          ..write(')'))
        .toString();
  }
}

class $SuggestionsTable extends Suggestions
    with TableInfo<$SuggestionsTable, Suggestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuggestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseLogIdMeta = const VerificationMeta(
    'exerciseLogId',
  );
  @override
  late final GeneratedColumn<int> exerciseLogId = GeneratedColumn<int>(
    'exercise_log_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercise_logs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paramsMeta = const VerificationMeta('params');
  @override
  late final GeneratedColumn<String> params = GeneratedColumn<String>(
    'params',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    exerciseLogId,
    ruleId,
    priority,
    params,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suggestions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Suggestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_log_id')) {
      context.handle(
        _exerciseLogIdMeta,
        exerciseLogId.isAcceptableOrUnknown(
          data['exercise_log_id']!,
          _exerciseLogIdMeta,
        ),
      );
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('params')) {
      context.handle(
        _paramsMeta,
        params.isAcceptableOrUnknown(data['params']!, _paramsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Suggestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Suggestion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_log_id'],
      ),
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_id'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      params: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}params'],
      )!,
    );
  }

  @override
  $SuggestionsTable createAlias(String alias) {
    return $SuggestionsTable(attachedDatabase, alias);
  }
}

class Suggestion extends DataClass implements Insertable<Suggestion> {
  final int id;
  final int sessionId;
  final int? exerciseLogId;
  final String ruleId;
  final int priority;

  /// JSON with the values needed to render the message text.
  final String params;
  const Suggestion({
    required this.id,
    required this.sessionId,
    this.exerciseLogId,
    required this.ruleId,
    required this.priority,
    required this.params,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    if (!nullToAbsent || exerciseLogId != null) {
      map['exercise_log_id'] = Variable<int>(exerciseLogId);
    }
    map['rule_id'] = Variable<String>(ruleId);
    map['priority'] = Variable<int>(priority);
    map['params'] = Variable<String>(params);
    return map;
  }

  SuggestionsCompanion toCompanion(bool nullToAbsent) {
    return SuggestionsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseLogId: exerciseLogId == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseLogId),
      ruleId: Value(ruleId),
      priority: Value(priority),
      params: Value(params),
    );
  }

  factory Suggestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Suggestion(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      exerciseLogId: serializer.fromJson<int?>(json['exerciseLogId']),
      ruleId: serializer.fromJson<String>(json['ruleId']),
      priority: serializer.fromJson<int>(json['priority']),
      params: serializer.fromJson<String>(json['params']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'exerciseLogId': serializer.toJson<int?>(exerciseLogId),
      'ruleId': serializer.toJson<String>(ruleId),
      'priority': serializer.toJson<int>(priority),
      'params': serializer.toJson<String>(params),
    };
  }

  Suggestion copyWith({
    int? id,
    int? sessionId,
    Value<int?> exerciseLogId = const Value.absent(),
    String? ruleId,
    int? priority,
    String? params,
  }) => Suggestion(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseLogId: exerciseLogId.present
        ? exerciseLogId.value
        : this.exerciseLogId,
    ruleId: ruleId ?? this.ruleId,
    priority: priority ?? this.priority,
    params: params ?? this.params,
  );
  Suggestion copyWithCompanion(SuggestionsCompanion data) {
    return Suggestion(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseLogId: data.exerciseLogId.present
          ? data.exerciseLogId.value
          : this.exerciseLogId,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      priority: data.priority.present ? data.priority.value : this.priority,
      params: data.params.present ? data.params.value : this.params,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Suggestion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseLogId: $exerciseLogId, ')
          ..write('ruleId: $ruleId, ')
          ..write('priority: $priority, ')
          ..write('params: $params')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, exerciseLogId, ruleId, priority, params);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Suggestion &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseLogId == this.exerciseLogId &&
          other.ruleId == this.ruleId &&
          other.priority == this.priority &&
          other.params == this.params);
}

class SuggestionsCompanion extends UpdateCompanion<Suggestion> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int?> exerciseLogId;
  final Value<String> ruleId;
  final Value<int> priority;
  final Value<String> params;
  const SuggestionsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseLogId = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.priority = const Value.absent(),
    this.params = const Value.absent(),
  });
  SuggestionsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    this.exerciseLogId = const Value.absent(),
    required String ruleId,
    required int priority,
    this.params = const Value.absent(),
  }) : sessionId = Value(sessionId),
       ruleId = Value(ruleId),
       priority = Value(priority);
  static Insertable<Suggestion> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? exerciseLogId,
    Expression<String>? ruleId,
    Expression<int>? priority,
    Expression<String>? params,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseLogId != null) 'exercise_log_id': exerciseLogId,
      if (ruleId != null) 'rule_id': ruleId,
      if (priority != null) 'priority': priority,
      if (params != null) 'params': params,
    });
  }

  SuggestionsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int?>? exerciseLogId,
    Value<String>? ruleId,
    Value<int>? priority,
    Value<String>? params,
  }) {
    return SuggestionsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseLogId: exerciseLogId ?? this.exerciseLogId,
      ruleId: ruleId ?? this.ruleId,
      priority: priority ?? this.priority,
      params: params ?? this.params,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (exerciseLogId.present) {
      map['exercise_log_id'] = Variable<int>(exerciseLogId.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (params.present) {
      map['params'] = Variable<String>(params.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuggestionsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseLogId: $exerciseLogId, ')
          ..write('ruleId: $ruleId, ')
          ..write('priority: $priority, ')
          ..write('params: $params')
          ..write(')'))
        .toString();
  }
}

class $StreakStatesTable extends StreakStates
    with TableInfo<$StreakStatesTable, StreakState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreakStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentWeeksMeta = const VerificationMeta(
    'currentWeeks',
  );
  @override
  late final GeneratedColumn<int> currentWeeks = GeneratedColumn<int>(
    'current_weeks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longestWeeksMeta = const VerificationMeta(
    'longestWeeks',
  );
  @override
  late final GeneratedColumn<int> longestWeeks = GeneratedColumn<int>(
    'longest_weeks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currentWeeks,
    longestWeeks,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streak_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<StreakState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('current_weeks')) {
      context.handle(
        _currentWeeksMeta,
        currentWeeks.isAcceptableOrUnknown(
          data['current_weeks']!,
          _currentWeeksMeta,
        ),
      );
    }
    if (data.containsKey('longest_weeks')) {
      context.handle(
        _longestWeeksMeta,
        longestWeeks.isAcceptableOrUnknown(
          data['longest_weeks']!,
          _longestWeeksMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StreakState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StreakState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      currentWeeks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_weeks'],
      )!,
      longestWeeks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_weeks'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StreakStatesTable createAlias(String alias) {
    return $StreakStatesTable(attachedDatabase, alias);
  }
}

class StreakState extends DataClass implements Insertable<StreakState> {
  final int id;
  final int currentWeeks;
  final int longestWeeks;
  final int updatedAt;
  const StreakState({
    required this.id,
    required this.currentWeeks,
    required this.longestWeeks,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['current_weeks'] = Variable<int>(currentWeeks);
    map['longest_weeks'] = Variable<int>(longestWeeks);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  StreakStatesCompanion toCompanion(bool nullToAbsent) {
    return StreakStatesCompanion(
      id: Value(id),
      currentWeeks: Value(currentWeeks),
      longestWeeks: Value(longestWeeks),
      updatedAt: Value(updatedAt),
    );
  }

  factory StreakState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StreakState(
      id: serializer.fromJson<int>(json['id']),
      currentWeeks: serializer.fromJson<int>(json['currentWeeks']),
      longestWeeks: serializer.fromJson<int>(json['longestWeeks']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currentWeeks': serializer.toJson<int>(currentWeeks),
      'longestWeeks': serializer.toJson<int>(longestWeeks),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  StreakState copyWith({
    int? id,
    int? currentWeeks,
    int? longestWeeks,
    int? updatedAt,
  }) => StreakState(
    id: id ?? this.id,
    currentWeeks: currentWeeks ?? this.currentWeeks,
    longestWeeks: longestWeeks ?? this.longestWeeks,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StreakState copyWithCompanion(StreakStatesCompanion data) {
    return StreakState(
      id: data.id.present ? data.id.value : this.id,
      currentWeeks: data.currentWeeks.present
          ? data.currentWeeks.value
          : this.currentWeeks,
      longestWeeks: data.longestWeeks.present
          ? data.longestWeeks.value
          : this.longestWeeks,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StreakState(')
          ..write('id: $id, ')
          ..write('currentWeeks: $currentWeeks, ')
          ..write('longestWeeks: $longestWeeks, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, currentWeeks, longestWeeks, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StreakState &&
          other.id == this.id &&
          other.currentWeeks == this.currentWeeks &&
          other.longestWeeks == this.longestWeeks &&
          other.updatedAt == this.updatedAt);
}

class StreakStatesCompanion extends UpdateCompanion<StreakState> {
  final Value<int> id;
  final Value<int> currentWeeks;
  final Value<int> longestWeeks;
  final Value<int> updatedAt;
  const StreakStatesCompanion({
    this.id = const Value.absent(),
    this.currentWeeks = const Value.absent(),
    this.longestWeeks = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  StreakStatesCompanion.insert({
    this.id = const Value.absent(),
    this.currentWeeks = const Value.absent(),
    this.longestWeeks = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<StreakState> custom({
    Expression<int>? id,
    Expression<int>? currentWeeks,
    Expression<int>? longestWeeks,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentWeeks != null) 'current_weeks': currentWeeks,
      if (longestWeeks != null) 'longest_weeks': longestWeeks,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  StreakStatesCompanion copyWith({
    Value<int>? id,
    Value<int>? currentWeeks,
    Value<int>? longestWeeks,
    Value<int>? updatedAt,
  }) {
    return StreakStatesCompanion(
      id: id ?? this.id,
      currentWeeks: currentWeeks ?? this.currentWeeks,
      longestWeeks: longestWeeks ?? this.longestWeeks,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currentWeeks.present) {
      map['current_weeks'] = Variable<int>(currentWeeks.value);
    }
    if (longestWeeks.present) {
      map['longest_weeks'] = Variable<int>(longestWeeks.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreakStatesCompanion(')
          ..write('id: $id, ')
          ..write('currentWeeks: $currentWeeks, ')
          ..write('longestWeeks: $longestWeeks, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $NutritionDaysTable extends NutritionDays
    with TableInfo<$NutritionDaysTable, NutritionDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutritionDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<int> protein = GeneratedColumn<int>(
    'protein',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [day, calories, protein];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrition_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<NutritionDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  NutritionDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NutritionDay(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      ),
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protein'],
      ),
    );
  }

  @override
  $NutritionDaysTable createAlias(String alias) {
    return $NutritionDaysTable(attachedDatabase, alias);
  }
}

class NutritionDay extends DataClass implements Insertable<NutritionDay> {
  final int day;
  final int? calories;
  final int? protein;
  const NutritionDay({required this.day, this.calories, this.protein});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<int>(day);
    if (!nullToAbsent || calories != null) {
      map['calories'] = Variable<int>(calories);
    }
    if (!nullToAbsent || protein != null) {
      map['protein'] = Variable<int>(protein);
    }
    return map;
  }

  NutritionDaysCompanion toCompanion(bool nullToAbsent) {
    return NutritionDaysCompanion(
      day: Value(day),
      calories: calories == null && nullToAbsent
          ? const Value.absent()
          : Value(calories),
      protein: protein == null && nullToAbsent
          ? const Value.absent()
          : Value(protein),
    );
  }

  factory NutritionDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NutritionDay(
      day: serializer.fromJson<int>(json['day']),
      calories: serializer.fromJson<int?>(json['calories']),
      protein: serializer.fromJson<int?>(json['protein']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<int>(day),
      'calories': serializer.toJson<int?>(calories),
      'protein': serializer.toJson<int?>(protein),
    };
  }

  NutritionDay copyWith({
    int? day,
    Value<int?> calories = const Value.absent(),
    Value<int?> protein = const Value.absent(),
  }) => NutritionDay(
    day: day ?? this.day,
    calories: calories.present ? calories.value : this.calories,
    protein: protein.present ? protein.value : this.protein,
  );
  NutritionDay copyWithCompanion(NutritionDaysCompanion data) {
    return NutritionDay(
      day: data.day.present ? data.day.value : this.day,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NutritionDay(')
          ..write('day: $day, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, calories, protein);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NutritionDay &&
          other.day == this.day &&
          other.calories == this.calories &&
          other.protein == this.protein);
}

class NutritionDaysCompanion extends UpdateCompanion<NutritionDay> {
  final Value<int> day;
  final Value<int?> calories;
  final Value<int?> protein;
  const NutritionDaysCompanion({
    this.day = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
  });
  NutritionDaysCompanion.insert({
    this.day = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
  });
  static Insertable<NutritionDay> custom({
    Expression<int>? day,
    Expression<int>? calories,
    Expression<int>? protein,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
    });
  }

  NutritionDaysCompanion copyWith({
    Value<int>? day,
    Value<int?>? calories,
    Value<int?>? protein,
  }) {
    return NutritionDaysCompanion(
      day: day ?? this.day,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<int>(protein.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutritionDaysCompanion(')
          ..write('day: $day, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProgramsTable programs = $ProgramsTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $ExerciseLogsTable exerciseLogs = $ExerciseLogsTable(this);
  late final $SetEntriesTable setEntries = $SetEntriesTable(this);
  late final $DaySummariesTable daySummaries = $DaySummariesTable(this);
  late final $WeekSummariesTable weekSummaries = $WeekSummariesTable(this);
  late final $ExerciseStatsTable exerciseStats = $ExerciseStatsTable(this);
  late final $SuggestionsTable suggestions = $SuggestionsTable(this);
  late final $StreakStatesTable streakStates = $StreakStatesTable(this);
  late final $NutritionDaysTable nutritionDays = $NutritionDaysTable(this);
  late final Index sessionProgramDay = Index(
    'session_program_day',
    'CREATE INDEX session_program_day ON sessions (program_id, day)',
  );
  late final Index exerciseLogExerciseDay = Index(
    'exercise_log_exercise_day',
    'CREATE INDEX exercise_log_exercise_day ON exercise_logs (exercise_id, day)',
  );
  late final Index suggestionSession = Index(
    'suggestion_session',
    'CREATE INDEX suggestion_session ON suggestions (session_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    programs,
    exercises,
    sessions,
    exerciseLogs,
    setEntries,
    daySummaries,
    weekSummaries,
    exerciseStats,
    suggestions,
    streakStates,
    nutritionDays,
    sessionProgramDay,
    exerciseLogExerciseDay,
    suggestionSession,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercise_logs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_logs', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercise_logs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('set_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('day_summaries', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_stats', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercise_logs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_stats', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('suggestions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercise_logs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('suggestions', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ProgramsTableCreateCompanionBuilder =
    ProgramsCompanion Function({
      Value<int> id,
      required String name,
      required String nameKey,
      Value<int> sortOrder,
      Value<bool> archived,
    });
typedef $$ProgramsTableUpdateCompanionBuilder =
    ProgramsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> nameKey,
      Value<int> sortOrder,
      Value<bool> archived,
    });

final class $$ProgramsTableReferences
    extends BaseReferences<_$AppDatabase, $ProgramsTable, Program> {
  $$ProgramsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExercisesTable, List<Exercise>>
  _exercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exercises,
    aliasName: 'programs__id__exercises__program_id',
  );

  $$ExercisesTableProcessedTableManager get exercisesRefs {
    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.programId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exercisesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: 'programs__id__sessions__program_id',
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.programId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProgramsTableFilterComposer
    extends Composer<_$AppDatabase, $ProgramsTable> {
  $$ProgramsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exercisesRefs(
    Expression<bool> Function($$ExercisesTableFilterComposer f) f,
  ) {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProgramsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgramsTable> {
  $$ProgramsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgramsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgramsTable> {
  $$ProgramsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> exercisesRefs<T extends Object>(
    Expression<T> Function($$ExercisesTableAnnotationComposer a) f,
  ) {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProgramsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgramsTable,
          Program,
          $$ProgramsTableFilterComposer,
          $$ProgramsTableOrderingComposer,
          $$ProgramsTableAnnotationComposer,
          $$ProgramsTableCreateCompanionBuilder,
          $$ProgramsTableUpdateCompanionBuilder,
          (Program, $$ProgramsTableReferences),
          Program,
          PrefetchHooks Function({bool exercisesRefs, bool sessionsRefs})
        > {
  $$ProgramsTableTableManager(_$AppDatabase db, $ProgramsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgramsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgramsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgramsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => ProgramsCompanion(
                id: id,
                name: name,
                nameKey: nameKey,
                sortOrder: sortOrder,
                archived: archived,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String nameKey,
                Value<int> sortOrder = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => ProgramsCompanion.insert(
                id: id,
                name: name,
                nameKey: nameKey,
                sortOrder: sortOrder,
                archived: archived,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProgramsTable, Program>(table),
                  $$ProgramsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({exercisesRefs = false, sessionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exercisesRefs) db.exercises,
                    if (sessionsRefs) db.sessions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exercisesRefs)
                        await $_getPrefetchedDataByColumns<
                          Program,
                          $ProgramsTable,
                          Exercise,
                          $ExercisesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProgramsTableReferences
                              ._exercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProgramsTableReferences(
                                db,
                                table,
                                p0,
                              ).exercisesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'program_id',
                          typedResults: items,
                        ),
                      if (sessionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Program,
                          $ProgramsTable,
                          Session,
                          $SessionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProgramsTableReferences
                              ._sessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProgramsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'program_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProgramsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgramsTable,
      Program,
      $$ProgramsTableFilterComposer,
      $$ProgramsTableOrderingComposer,
      $$ProgramsTableAnnotationComposer,
      $$ProgramsTableCreateCompanionBuilder,
      $$ProgramsTableUpdateCompanionBuilder,
      (Program, $$ProgramsTableReferences),
      Program,
      PrefetchHooks Function({bool exercisesRefs, bool sessionsRefs})
    >;
typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      required int programId,
      required String name,
      required String nameKey,
      required ExerciseType type,
      Value<bool> archived,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      Value<int> programId,
      Value<String> name,
      Value<String> nameKey,
      Value<ExerciseType> type,
      Value<bool> archived,
    });

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProgramsTable _programIdTable(_$AppDatabase db) =>
      db.programs.createAlias('exercises__program_id__programs__id');

  $$ProgramsTableProcessedTableManager get programId {
    final $_column = $_itemColumn<int>('program_id')!;

    final manager = $$ProgramsTableTableManager(
      $_db,
      $_db.programs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_programIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExerciseLogsTable, List<ExerciseLog>>
  _exerciseLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseLogs,
    aliasName: 'exercises__id__exercise_logs__exercise_id',
  );

  $$ExerciseLogsTableProcessedTableManager get exerciseLogsRefs {
    final manager = $$ExerciseLogsTableTableManager(
      $_db,
      $_db.exerciseLogs,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseStatsTable, List<ExerciseStat>>
  _exerciseStatsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseStats,
    aliasName: 'exercises__id__exercise_stats__exercise_id',
  );

  $$ExerciseStatsTableProcessedTableManager get exerciseStatsRefs {
    final manager = $$ExerciseStatsTableTableManager(
      $_db,
      $_db.exerciseStats,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseStatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ExerciseType, ExerciseType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  $$ProgramsTableFilterComposer get programId {
    final $$ProgramsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableFilterComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> exerciseLogsRefs(
    Expression<bool> Function($$ExerciseLogsTableFilterComposer f) f,
  ) {
    final $$ExerciseLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseStatsRefs(
    Expression<bool> Function($$ExerciseStatsTableFilterComposer f) f,
  ) {
    final $$ExerciseStatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseStats,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseStatsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProgramsTableOrderingComposer get programId {
    final $$ProgramsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableOrderingComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExerciseType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  $$ProgramsTableAnnotationComposer get programId {
    final $$ProgramsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableAnnotationComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> exerciseLogsRefs<T extends Object>(
    Expression<T> Function($$ExerciseLogsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseStatsRefs<T extends Object>(
    Expression<T> Function($$ExerciseStatsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseStatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseStats,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseStatsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({
            bool programId,
            bool exerciseLogsRefs,
            bool exerciseStatsRefs,
          })
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> programId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<ExerciseType> type = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                programId: programId,
                name: name,
                nameKey: nameKey,
                type: type,
                archived: archived,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int programId,
                required String name,
                required String nameKey,
                required ExerciseType type,
                Value<bool> archived = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                programId: programId,
                name: name,
                nameKey: nameKey,
                type: type,
                archived: archived,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExercisesTable, Exercise>(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                programId = false,
                exerciseLogsRefs = false,
                exerciseStatsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseLogsRefs) db.exerciseLogs,
                    if (exerciseStatsRefs) db.exerciseStats,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (programId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.programId,
                                    referencedTable: $$ExercisesTableReferences
                                        ._programIdTable(db),
                                    referencedColumn: $$ExercisesTableReferences
                                        ._programIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseLogsRefs)
                        await $_getPrefetchedDataByColumns<
                          Exercise,
                          $ExercisesTable,
                          ExerciseLog,
                          $ExerciseLogsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseLogsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_id',
                          typedResults: items,
                        ),
                      if (exerciseStatsRefs)
                        await $_getPrefetchedDataByColumns<
                          Exercise,
                          $ExercisesTable,
                          ExerciseStat,
                          $ExerciseStatsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseStatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseStatsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({
        bool programId,
        bool exerciseLogsRefs,
        bool exerciseStatsRefs,
      })
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required int day,
      required int programId,
      Value<int?> timeIn,
      Value<int?> timeOut,
      Value<int> volume,
      Value<int> setCount,
      Value<int?> summaryPct,
      Value<int?> prevSessionId,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<int> day,
      Value<int> programId,
      Value<int?> timeIn,
      Value<int?> timeOut,
      Value<int> volume,
      Value<int> setCount,
      Value<int?> summaryPct,
      Value<int?> prevSessionId,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProgramsTable _programIdTable(_$AppDatabase db) =>
      db.programs.createAlias('sessions__program_id__programs__id');

  $$ProgramsTableProcessedTableManager get programId {
    final $_column = $_itemColumn<int>('program_id')!;

    final manager = $$ProgramsTableTableManager(
      $_db,
      $_db.programs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_programIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SessionsTable _prevSessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('sessions__prev_session_id__sessions__id');

  $$SessionsTableProcessedTableManager? get prevSessionId {
    final $_column = $_itemColumn<int>('prev_session_id');
    if ($_column == null) return null;
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_prevSessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExerciseLogsTable, List<ExerciseLog>>
  _exerciseLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseLogs,
    aliasName: 'sessions__id__exercise_logs__session_id',
  );

  $$ExerciseLogsTableProcessedTableManager get exerciseLogsRefs {
    final manager = $$ExerciseLogsTableTableManager(
      $_db,
      $_db.exerciseLogs,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DaySummariesTable, List<DaySummary>>
  _daySummariesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.daySummaries,
    aliasName: 'sessions__id__day_summaries__session_id',
  );

  $$DaySummariesTableProcessedTableManager get daySummariesRefs {
    final manager = $$DaySummariesTableTableManager(
      $_db,
      $_db.daySummaries,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_daySummariesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SuggestionsTable, List<Suggestion>>
  _suggestionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.suggestions,
    aliasName: 'sessions__id__suggestions__session_id',
  );

  $$SuggestionsTableProcessedTableManager get suggestionsRefs {
    final manager = $$SuggestionsTableTableManager(
      $_db,
      $_db.suggestions,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_suggestionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeIn => $composableBuilder(
    column: $table.timeIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeOut => $composableBuilder(
    column: $table.timeOut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setCount => $composableBuilder(
    column: $table.setCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get summaryPct => $composableBuilder(
    column: $table.summaryPct,
    builder: (column) => ColumnFilters(column),
  );

  $$ProgramsTableFilterComposer get programId {
    final $$ProgramsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableFilterComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableFilterComposer get prevSessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prevSessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> exerciseLogsRefs(
    Expression<bool> Function($$ExerciseLogsTableFilterComposer f) f,
  ) {
    final $$ExerciseLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> daySummariesRefs(
    Expression<bool> Function($$DaySummariesTableFilterComposer f) f,
  ) {
    final $$DaySummariesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.daySummaries,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaySummariesTableFilterComposer(
            $db: $db,
            $table: $db.daySummaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> suggestionsRefs(
    Expression<bool> Function($$SuggestionsTableFilterComposer f) f,
  ) {
    final $$SuggestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.suggestions,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuggestionsTableFilterComposer(
            $db: $db,
            $table: $db.suggestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeIn => $composableBuilder(
    column: $table.timeIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeOut => $composableBuilder(
    column: $table.timeOut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setCount => $composableBuilder(
    column: $table.setCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get summaryPct => $composableBuilder(
    column: $table.summaryPct,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProgramsTableOrderingComposer get programId {
    final $$ProgramsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableOrderingComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableOrderingComposer get prevSessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prevSessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get timeIn =>
      $composableBuilder(column: $table.timeIn, builder: (column) => column);

  GeneratedColumn<int> get timeOut =>
      $composableBuilder(column: $table.timeOut, builder: (column) => column);

  GeneratedColumn<int> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<int> get setCount =>
      $composableBuilder(column: $table.setCount, builder: (column) => column);

  GeneratedColumn<int> get summaryPct => $composableBuilder(
    column: $table.summaryPct,
    builder: (column) => column,
  );

  $$ProgramsTableAnnotationComposer get programId {
    final $$ProgramsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableAnnotationComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableAnnotationComposer get prevSessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prevSessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> exerciseLogsRefs<T extends Object>(
    Expression<T> Function($$ExerciseLogsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> daySummariesRefs<T extends Object>(
    Expression<T> Function($$DaySummariesTableAnnotationComposer a) f,
  ) {
    final $$DaySummariesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.daySummaries,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaySummariesTableAnnotationComposer(
            $db: $db,
            $table: $db.daySummaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> suggestionsRefs<T extends Object>(
    Expression<T> Function($$SuggestionsTableAnnotationComposer a) f,
  ) {
    final $$SuggestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.suggestions,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuggestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.suggestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({
            bool programId,
            bool prevSessionId,
            bool exerciseLogsRefs,
            bool daySummariesRefs,
            bool suggestionsRefs,
          })
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> day = const Value.absent(),
                Value<int> programId = const Value.absent(),
                Value<int?> timeIn = const Value.absent(),
                Value<int?> timeOut = const Value.absent(),
                Value<int> volume = const Value.absent(),
                Value<int> setCount = const Value.absent(),
                Value<int?> summaryPct = const Value.absent(),
                Value<int?> prevSessionId = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                day: day,
                programId: programId,
                timeIn: timeIn,
                timeOut: timeOut,
                volume: volume,
                setCount: setCount,
                summaryPct: summaryPct,
                prevSessionId: prevSessionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int day,
                required int programId,
                Value<int?> timeIn = const Value.absent(),
                Value<int?> timeOut = const Value.absent(),
                Value<int> volume = const Value.absent(),
                Value<int> setCount = const Value.absent(),
                Value<int?> summaryPct = const Value.absent(),
                Value<int?> prevSessionId = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                day: day,
                programId: programId,
                timeIn: timeIn,
                timeOut: timeOut,
                volume: volume,
                setCount: setCount,
                summaryPct: summaryPct,
                prevSessionId: prevSessionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, Session>(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                programId = false,
                prevSessionId = false,
                exerciseLogsRefs = false,
                daySummariesRefs = false,
                suggestionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseLogsRefs) db.exerciseLogs,
                    if (daySummariesRefs) db.daySummaries,
                    if (suggestionsRefs) db.suggestions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (programId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.programId,
                                    referencedTable: $$SessionsTableReferences
                                        ._programIdTable(db),
                                    referencedColumn: $$SessionsTableReferences
                                        ._programIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (prevSessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.prevSessionId,
                                    referencedTable: $$SessionsTableReferences
                                        ._prevSessionIdTable(db),
                                    referencedColumn: $$SessionsTableReferences
                                        ._prevSessionIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseLogsRefs)
                        await $_getPrefetchedDataByColumns<
                          Session,
                          $SessionsTable,
                          ExerciseLog,
                          $ExerciseLogsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._exerciseLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseLogsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (daySummariesRefs)
                        await $_getPrefetchedDataByColumns<
                          Session,
                          $SessionsTable,
                          DaySummary,
                          $DaySummariesTable
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._daySummariesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).daySummariesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (suggestionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Session,
                          $SessionsTable,
                          Suggestion,
                          $SuggestionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._suggestionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).suggestionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({
        bool programId,
        bool prevSessionId,
        bool exerciseLogsRefs,
        bool daySummariesRefs,
        bool suggestionsRefs,
      })
    >;
typedef $$ExerciseLogsTableCreateCompanionBuilder =
    ExerciseLogsCompanion Function({
      Value<int> id,
      required int sessionId,
      required int exerciseId,
      required int day,
      Value<int> sortOrder,
      Value<int> volume,
      Value<int> setCount,
      Value<int?> bestWeight,
      Value<int> repsAtTop,
      Value<int?> pct,
      Value<int?> prevLogId,
    });
typedef $$ExerciseLogsTableUpdateCompanionBuilder =
    ExerciseLogsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> exerciseId,
      Value<int> day,
      Value<int> sortOrder,
      Value<int> volume,
      Value<int> setCount,
      Value<int?> bestWeight,
      Value<int> repsAtTop,
      Value<int?> pct,
      Value<int?> prevLogId,
    });

final class $$ExerciseLogsTableReferences
    extends BaseReferences<_$AppDatabase, $ExerciseLogsTable, ExerciseLog> {
  $$ExerciseLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('exercise_logs__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('exercise_logs__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExerciseLogsTable _prevLogIdTable(_$AppDatabase db) => db.exerciseLogs
      .createAlias('exercise_logs__prev_log_id__exercise_logs__id');

  $$ExerciseLogsTableProcessedTableManager? get prevLogId {
    final $_column = $_itemColumn<int>('prev_log_id');
    if ($_column == null) return null;
    final manager = $$ExerciseLogsTableTableManager(
      $_db,
      $_db.exerciseLogs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_prevLogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SetEntriesTable, List<SetEntry>>
  _setEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.setEntries,
    aliasName: 'exercise_logs__id__set_entries__exercise_log_id',
  );

  $$SetEntriesTableProcessedTableManager get setEntriesRefs {
    final manager = $$SetEntriesTableTableManager(
      $_db,
      $_db.setEntries,
    ).filter((f) => f.exerciseLogId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_setEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseStatsTable, List<ExerciseStat>>
  _exerciseStatsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseStats,
    aliasName: 'exercise_logs__id__exercise_stats__last_log_id',
  );

  $$ExerciseStatsTableProcessedTableManager get exerciseStatsRefs {
    final manager = $$ExerciseStatsTableTableManager(
      $_db,
      $_db.exerciseStats,
    ).filter((f) => f.lastLogId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseStatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SuggestionsTable, List<Suggestion>>
  _suggestionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.suggestions,
    aliasName: 'exercise_logs__id__suggestions__exercise_log_id',
  );

  $$SuggestionsTableProcessedTableManager get suggestionsRefs {
    final manager = $$SuggestionsTableTableManager(
      $_db,
      $_db.suggestions,
    ).filter((f) => f.exerciseLogId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_suggestionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExerciseLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseLogsTable> {
  $$ExerciseLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setCount => $composableBuilder(
    column: $table.setCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestWeight => $composableBuilder(
    column: $table.bestWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repsAtTop => $composableBuilder(
    column: $table.repsAtTop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pct => $composableBuilder(
    column: $table.pct,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseLogsTableFilterComposer get prevLogId {
    final $$ExerciseLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prevLogId,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> setEntriesRefs(
    Expression<bool> Function($$SetEntriesTableFilterComposer f) f,
  ) {
    final $$SetEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setEntries,
      getReferencedColumn: (t) => t.exerciseLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetEntriesTableFilterComposer(
            $db: $db,
            $table: $db.setEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseStatsRefs(
    Expression<bool> Function($$ExerciseStatsTableFilterComposer f) f,
  ) {
    final $$ExerciseStatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseStats,
      getReferencedColumn: (t) => t.lastLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseStatsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> suggestionsRefs(
    Expression<bool> Function($$SuggestionsTableFilterComposer f) f,
  ) {
    final $$SuggestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.suggestions,
      getReferencedColumn: (t) => t.exerciseLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuggestionsTableFilterComposer(
            $db: $db,
            $table: $db.suggestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciseLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseLogsTable> {
  $$ExerciseLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setCount => $composableBuilder(
    column: $table.setCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestWeight => $composableBuilder(
    column: $table.bestWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repsAtTop => $composableBuilder(
    column: $table.repsAtTop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pct => $composableBuilder(
    column: $table.pct,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseLogsTableOrderingComposer get prevLogId {
    final $$ExerciseLogsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prevLogId,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseLogsTable> {
  $$ExerciseLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<int> get setCount =>
      $composableBuilder(column: $table.setCount, builder: (column) => column);

  GeneratedColumn<int> get bestWeight => $composableBuilder(
    column: $table.bestWeight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repsAtTop =>
      $composableBuilder(column: $table.repsAtTop, builder: (column) => column);

  GeneratedColumn<int> get pct =>
      $composableBuilder(column: $table.pct, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseLogsTableAnnotationComposer get prevLogId {
    final $$ExerciseLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prevLogId,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> setEntriesRefs<T extends Object>(
    Expression<T> Function($$SetEntriesTableAnnotationComposer a) f,
  ) {
    final $$SetEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setEntries,
      getReferencedColumn: (t) => t.exerciseLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.setEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseStatsRefs<T extends Object>(
    Expression<T> Function($$ExerciseStatsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseStatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseStats,
      getReferencedColumn: (t) => t.lastLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseStatsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> suggestionsRefs<T extends Object>(
    Expression<T> Function($$SuggestionsTableAnnotationComposer a) f,
  ) {
    final $$SuggestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.suggestions,
      getReferencedColumn: (t) => t.exerciseLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuggestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.suggestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciseLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseLogsTable,
          ExerciseLog,
          $$ExerciseLogsTableFilterComposer,
          $$ExerciseLogsTableOrderingComposer,
          $$ExerciseLogsTableAnnotationComposer,
          $$ExerciseLogsTableCreateCompanionBuilder,
          $$ExerciseLogsTableUpdateCompanionBuilder,
          (ExerciseLog, $$ExerciseLogsTableReferences),
          ExerciseLog,
          PrefetchHooks Function({
            bool sessionId,
            bool exerciseId,
            bool prevLogId,
            bool setEntriesRefs,
            bool exerciseStatsRefs,
            bool suggestionsRefs,
          })
        > {
  $$ExerciseLogsTableTableManager(_$AppDatabase db, $ExerciseLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> day = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> volume = const Value.absent(),
                Value<int> setCount = const Value.absent(),
                Value<int?> bestWeight = const Value.absent(),
                Value<int> repsAtTop = const Value.absent(),
                Value<int?> pct = const Value.absent(),
                Value<int?> prevLogId = const Value.absent(),
              }) => ExerciseLogsCompanion(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                day: day,
                sortOrder: sortOrder,
                volume: volume,
                setCount: setCount,
                bestWeight: bestWeight,
                repsAtTop: repsAtTop,
                pct: pct,
                prevLogId: prevLogId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int exerciseId,
                required int day,
                Value<int> sortOrder = const Value.absent(),
                Value<int> volume = const Value.absent(),
                Value<int> setCount = const Value.absent(),
                Value<int?> bestWeight = const Value.absent(),
                Value<int> repsAtTop = const Value.absent(),
                Value<int?> pct = const Value.absent(),
                Value<int?> prevLogId = const Value.absent(),
              }) => ExerciseLogsCompanion.insert(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                day: day,
                sortOrder: sortOrder,
                volume: volume,
                setCount: setCount,
                bestWeight: bestWeight,
                repsAtTop: repsAtTop,
                pct: pct,
                prevLogId: prevLogId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExerciseLogsTable, ExerciseLog>(table),
                  $$ExerciseLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sessionId = false,
                exerciseId = false,
                prevLogId = false,
                setEntriesRefs = false,
                exerciseStatsRefs = false,
                suggestionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (setEntriesRefs) db.setEntries,
                    if (exerciseStatsRefs) db.exerciseStats,
                    if (suggestionsRefs) db.suggestions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable:
                                        $$ExerciseLogsTableReferences
                                            ._sessionIdTable(db),
                                    referencedColumn:
                                        $$ExerciseLogsTableReferences
                                            ._sessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (exerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.exerciseId,
                                    referencedTable:
                                        $$ExerciseLogsTableReferences
                                            ._exerciseIdTable(db),
                                    referencedColumn:
                                        $$ExerciseLogsTableReferences
                                            ._exerciseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (prevLogId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.prevLogId,
                                    referencedTable:
                                        $$ExerciseLogsTableReferences
                                            ._prevLogIdTable(db),
                                    referencedColumn:
                                        $$ExerciseLogsTableReferences
                                            ._prevLogIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (setEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          ExerciseLog,
                          $ExerciseLogsTable,
                          SetEntry,
                          $SetEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExerciseLogsTableReferences
                              ._setEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExerciseLogsTableReferences(
                                db,
                                table,
                                p0,
                              ).setEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_log_id',
                          typedResults: items,
                        ),
                      if (exerciseStatsRefs)
                        await $_getPrefetchedDataByColumns<
                          ExerciseLog,
                          $ExerciseLogsTable,
                          ExerciseStat,
                          $ExerciseStatsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExerciseLogsTableReferences
                              ._exerciseStatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExerciseLogsTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseStatsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'last_log_id',
                          typedResults: items,
                        ),
                      if (suggestionsRefs)
                        await $_getPrefetchedDataByColumns<
                          ExerciseLog,
                          $ExerciseLogsTable,
                          Suggestion,
                          $SuggestionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExerciseLogsTableReferences
                              ._suggestionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExerciseLogsTableReferences(
                                db,
                                table,
                                p0,
                              ).suggestionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_log_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExerciseLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseLogsTable,
      ExerciseLog,
      $$ExerciseLogsTableFilterComposer,
      $$ExerciseLogsTableOrderingComposer,
      $$ExerciseLogsTableAnnotationComposer,
      $$ExerciseLogsTableCreateCompanionBuilder,
      $$ExerciseLogsTableUpdateCompanionBuilder,
      (ExerciseLog, $$ExerciseLogsTableReferences),
      ExerciseLog,
      PrefetchHooks Function({
        bool sessionId,
        bool exerciseId,
        bool prevLogId,
        bool setEntriesRefs,
        bool exerciseStatsRefs,
        bool suggestionsRefs,
      })
    >;
typedef $$SetEntriesTableCreateCompanionBuilder =
    SetEntriesCompanion Function({
      Value<int> id,
      required int exerciseLogId,
      required int idx,
      Value<int?> weight,
      required int reps,
    });
typedef $$SetEntriesTableUpdateCompanionBuilder =
    SetEntriesCompanion Function({
      Value<int> id,
      Value<int> exerciseLogId,
      Value<int> idx,
      Value<int?> weight,
      Value<int> reps,
    });

final class $$SetEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $SetEntriesTable, SetEntry> {
  $$SetEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExerciseLogsTable _exerciseLogIdTable(_$AppDatabase db) => db
      .exerciseLogs
      .createAlias('set_entries__exercise_log_id__exercise_logs__id');

  $$ExerciseLogsTableProcessedTableManager get exerciseLogId {
    final $_column = $_itemColumn<int>('exercise_log_id')!;

    final manager = $$ExerciseLogsTableTableManager(
      $_db,
      $_db.exerciseLogs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseLogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SetEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SetEntriesTable> {
  $$SetEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  $$ExerciseLogsTableFilterComposer get exerciseLogId {
    final $$ExerciseLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseLogId,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SetEntriesTable> {
  $$SetEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExerciseLogsTableOrderingComposer get exerciseLogId {
    final $$ExerciseLogsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseLogId,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetEntriesTable> {
  $$SetEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get idx =>
      $composableBuilder(column: $table.idx, builder: (column) => column);

  GeneratedColumn<int> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  $$ExerciseLogsTableAnnotationComposer get exerciseLogId {
    final $$ExerciseLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseLogId,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SetEntriesTable,
          SetEntry,
          $$SetEntriesTableFilterComposer,
          $$SetEntriesTableOrderingComposer,
          $$SetEntriesTableAnnotationComposer,
          $$SetEntriesTableCreateCompanionBuilder,
          $$SetEntriesTableUpdateCompanionBuilder,
          (SetEntry, $$SetEntriesTableReferences),
          SetEntry,
          PrefetchHooks Function({bool exerciseLogId})
        > {
  $$SetEntriesTableTableManager(_$AppDatabase db, $SetEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> exerciseLogId = const Value.absent(),
                Value<int> idx = const Value.absent(),
                Value<int?> weight = const Value.absent(),
                Value<int> reps = const Value.absent(),
              }) => SetEntriesCompanion(
                id: id,
                exerciseLogId: exerciseLogId,
                idx: idx,
                weight: weight,
                reps: reps,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int exerciseLogId,
                required int idx,
                Value<int?> weight = const Value.absent(),
                required int reps,
              }) => SetEntriesCompanion.insert(
                id: id,
                exerciseLogId: exerciseLogId,
                idx: idx,
                weight: weight,
                reps: reps,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SetEntriesTable, SetEntry>(table),
                  $$SetEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseLogId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (exerciseLogId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseLogId,
                                referencedTable: $$SetEntriesTableReferences
                                    ._exerciseLogIdTable(db),
                                referencedColumn: $$SetEntriesTableReferences
                                    ._exerciseLogIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SetEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SetEntriesTable,
      SetEntry,
      $$SetEntriesTableFilterComposer,
      $$SetEntriesTableOrderingComposer,
      $$SetEntriesTableAnnotationComposer,
      $$SetEntriesTableCreateCompanionBuilder,
      $$SetEntriesTableUpdateCompanionBuilder,
      (SetEntry, $$SetEntriesTableReferences),
      SetEntry,
      PrefetchHooks Function({bool exerciseLogId})
    >;
typedef $$DaySummariesTableCreateCompanionBuilder =
    DaySummariesCompanion Function({
      Value<int> day,
      Value<int?> sessionId,
      Value<int> setCount,
      Value<bool> isRest,
    });
typedef $$DaySummariesTableUpdateCompanionBuilder =
    DaySummariesCompanion Function({
      Value<int> day,
      Value<int?> sessionId,
      Value<int> setCount,
      Value<bool> isRest,
    });

final class $$DaySummariesTableReferences
    extends BaseReferences<_$AppDatabase, $DaySummariesTable, DaySummary> {
  $$DaySummariesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('day_summaries__session_id__sessions__id');

  $$SessionsTableProcessedTableManager? get sessionId {
    final $_column = $_itemColumn<int>('session_id');
    if ($_column == null) return null;
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DaySummariesTableFilterComposer
    extends Composer<_$AppDatabase, $DaySummariesTable> {
  $$DaySummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setCount => $composableBuilder(
    column: $table.setCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRest => $composableBuilder(
    column: $table.isRest,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DaySummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $DaySummariesTable> {
  $$DaySummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setCount => $composableBuilder(
    column: $table.setCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRest => $composableBuilder(
    column: $table.isRest,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DaySummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DaySummariesTable> {
  $$DaySummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get setCount =>
      $composableBuilder(column: $table.setCount, builder: (column) => column);

  GeneratedColumn<bool> get isRest =>
      $composableBuilder(column: $table.isRest, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DaySummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DaySummariesTable,
          DaySummary,
          $$DaySummariesTableFilterComposer,
          $$DaySummariesTableOrderingComposer,
          $$DaySummariesTableAnnotationComposer,
          $$DaySummariesTableCreateCompanionBuilder,
          $$DaySummariesTableUpdateCompanionBuilder,
          (DaySummary, $$DaySummariesTableReferences),
          DaySummary,
          PrefetchHooks Function({bool sessionId})
        > {
  $$DaySummariesTableTableManager(_$AppDatabase db, $DaySummariesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DaySummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DaySummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DaySummariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> day = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<int> setCount = const Value.absent(),
                Value<bool> isRest = const Value.absent(),
              }) => DaySummariesCompanion(
                day: day,
                sessionId: sessionId,
                setCount: setCount,
                isRest: isRest,
              ),
          createCompanionCallback:
              ({
                Value<int> day = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<int> setCount = const Value.absent(),
                Value<bool> isRest = const Value.absent(),
              }) => DaySummariesCompanion.insert(
                day: day,
                sessionId: sessionId,
                setCount: setCount,
                isRest: isRest,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DaySummariesTable, DaySummary>(table),
                  $$DaySummariesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$DaySummariesTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$DaySummariesTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DaySummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DaySummariesTable,
      DaySummary,
      $$DaySummariesTableFilterComposer,
      $$DaySummariesTableOrderingComposer,
      $$DaySummariesTableAnnotationComposer,
      $$DaySummariesTableCreateCompanionBuilder,
      $$DaySummariesTableUpdateCompanionBuilder,
      (DaySummary, $$DaySummariesTableReferences),
      DaySummary,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$WeekSummariesTableCreateCompanionBuilder =
    WeekSummariesCompanion Function({
      Value<int> weekStart,
      Value<int> sessionCount,
    });
typedef $$WeekSummariesTableUpdateCompanionBuilder =
    WeekSummariesCompanion Function({
      Value<int> weekStart,
      Value<int> sessionCount,
    });

class $$WeekSummariesTableFilterComposer
    extends Composer<_$AppDatabase, $WeekSummariesTable> {
  $$WeekSummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionCount => $composableBuilder(
    column: $table.sessionCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeekSummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $WeekSummariesTable> {
  $$WeekSummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionCount => $composableBuilder(
    column: $table.sessionCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeekSummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeekSummariesTable> {
  $$WeekSummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<int> get sessionCount => $composableBuilder(
    column: $table.sessionCount,
    builder: (column) => column,
  );
}

class $$WeekSummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeekSummariesTable,
          WeekSummary,
          $$WeekSummariesTableFilterComposer,
          $$WeekSummariesTableOrderingComposer,
          $$WeekSummariesTableAnnotationComposer,
          $$WeekSummariesTableCreateCompanionBuilder,
          $$WeekSummariesTableUpdateCompanionBuilder,
          (
            WeekSummary,
            BaseReferences<_$AppDatabase, $WeekSummariesTable, WeekSummary>,
          ),
          WeekSummary,
          PrefetchHooks Function()
        > {
  $$WeekSummariesTableTableManager(_$AppDatabase db, $WeekSummariesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeekSummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeekSummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeekSummariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> weekStart = const Value.absent(),
                Value<int> sessionCount = const Value.absent(),
              }) => WeekSummariesCompanion(
                weekStart: weekStart,
                sessionCount: sessionCount,
              ),
          createCompanionCallback:
              ({
                Value<int> weekStart = const Value.absent(),
                Value<int> sessionCount = const Value.absent(),
              }) => WeekSummariesCompanion.insert(
                weekStart: weekStart,
                sessionCount: sessionCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeekSummariesTable, WeekSummary>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WeekSummariesTable,
                    WeekSummary
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeekSummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeekSummariesTable,
      WeekSummary,
      $$WeekSummariesTableFilterComposer,
      $$WeekSummariesTableOrderingComposer,
      $$WeekSummariesTableAnnotationComposer,
      $$WeekSummariesTableCreateCompanionBuilder,
      $$WeekSummariesTableUpdateCompanionBuilder,
      (
        WeekSummary,
        BaseReferences<_$AppDatabase, $WeekSummariesTable, WeekSummary>,
      ),
      WeekSummary,
      PrefetchHooks Function()
    >;
typedef $$ExerciseStatsTableCreateCompanionBuilder =
    ExerciseStatsCompanion Function({
      Value<int> exerciseId,
      Value<int?> bestWeight,
      Value<int?> bestRepsAtWeight,
      Value<int> bestVolume,
      Value<int?> lastLogId,
    });
typedef $$ExerciseStatsTableUpdateCompanionBuilder =
    ExerciseStatsCompanion Function({
      Value<int> exerciseId,
      Value<int?> bestWeight,
      Value<int?> bestRepsAtWeight,
      Value<int> bestVolume,
      Value<int?> lastLogId,
    });

final class $$ExerciseStatsTableReferences
    extends BaseReferences<_$AppDatabase, $ExerciseStatsTable, ExerciseStat> {
  $$ExerciseStatsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('exercise_stats__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExerciseLogsTable _lastLogIdTable(_$AppDatabase db) => db.exerciseLogs
      .createAlias('exercise_stats__last_log_id__exercise_logs__id');

  $$ExerciseLogsTableProcessedTableManager? get lastLogId {
    final $_column = $_itemColumn<int>('last_log_id');
    if ($_column == null) return null;
    final manager = $$ExerciseLogsTableTableManager(
      $_db,
      $_db.exerciseLogs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lastLogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseStatsTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseStatsTable> {
  $$ExerciseStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get bestWeight => $composableBuilder(
    column: $table.bestWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestRepsAtWeight => $composableBuilder(
    column: $table.bestRepsAtWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestVolume => $composableBuilder(
    column: $table.bestVolume,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseLogsTableFilterComposer get lastLogId {
    final $$ExerciseLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastLogId,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseStatsTable> {
  $$ExerciseStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get bestWeight => $composableBuilder(
    column: $table.bestWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestRepsAtWeight => $composableBuilder(
    column: $table.bestRepsAtWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestVolume => $composableBuilder(
    column: $table.bestVolume,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseLogsTableOrderingComposer get lastLogId {
    final $$ExerciseLogsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastLogId,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseStatsTable> {
  $$ExerciseStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get bestWeight => $composableBuilder(
    column: $table.bestWeight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestRepsAtWeight => $composableBuilder(
    column: $table.bestRepsAtWeight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestVolume => $composableBuilder(
    column: $table.bestVolume,
    builder: (column) => column,
  );

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseLogsTableAnnotationComposer get lastLogId {
    final $$ExerciseLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastLogId,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseStatsTable,
          ExerciseStat,
          $$ExerciseStatsTableFilterComposer,
          $$ExerciseStatsTableOrderingComposer,
          $$ExerciseStatsTableAnnotationComposer,
          $$ExerciseStatsTableCreateCompanionBuilder,
          $$ExerciseStatsTableUpdateCompanionBuilder,
          (ExerciseStat, $$ExerciseStatsTableReferences),
          ExerciseStat,
          PrefetchHooks Function({bool exerciseId, bool lastLogId})
        > {
  $$ExerciseStatsTableTableManager(_$AppDatabase db, $ExerciseStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> exerciseId = const Value.absent(),
                Value<int?> bestWeight = const Value.absent(),
                Value<int?> bestRepsAtWeight = const Value.absent(),
                Value<int> bestVolume = const Value.absent(),
                Value<int?> lastLogId = const Value.absent(),
              }) => ExerciseStatsCompanion(
                exerciseId: exerciseId,
                bestWeight: bestWeight,
                bestRepsAtWeight: bestRepsAtWeight,
                bestVolume: bestVolume,
                lastLogId: lastLogId,
              ),
          createCompanionCallback:
              ({
                Value<int> exerciseId = const Value.absent(),
                Value<int?> bestWeight = const Value.absent(),
                Value<int?> bestRepsAtWeight = const Value.absent(),
                Value<int> bestVolume = const Value.absent(),
                Value<int?> lastLogId = const Value.absent(),
              }) => ExerciseStatsCompanion.insert(
                exerciseId: exerciseId,
                bestWeight: bestWeight,
                bestRepsAtWeight: bestRepsAtWeight,
                bestVolume: bestVolume,
                lastLogId: lastLogId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExerciseStatsTable, ExerciseStat>(table),
                  $$ExerciseStatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false, lastLogId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$ExerciseStatsTableReferences
                                    ._exerciseIdTable(db),
                                referencedColumn: $$ExerciseStatsTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (lastLogId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.lastLogId,
                                referencedTable: $$ExerciseStatsTableReferences
                                    ._lastLogIdTable(db),
                                referencedColumn: $$ExerciseStatsTableReferences
                                    ._lastLogIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExerciseStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseStatsTable,
      ExerciseStat,
      $$ExerciseStatsTableFilterComposer,
      $$ExerciseStatsTableOrderingComposer,
      $$ExerciseStatsTableAnnotationComposer,
      $$ExerciseStatsTableCreateCompanionBuilder,
      $$ExerciseStatsTableUpdateCompanionBuilder,
      (ExerciseStat, $$ExerciseStatsTableReferences),
      ExerciseStat,
      PrefetchHooks Function({bool exerciseId, bool lastLogId})
    >;
typedef $$SuggestionsTableCreateCompanionBuilder =
    SuggestionsCompanion Function({
      Value<int> id,
      required int sessionId,
      Value<int?> exerciseLogId,
      required String ruleId,
      required int priority,
      Value<String> params,
    });
typedef $$SuggestionsTableUpdateCompanionBuilder =
    SuggestionsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int?> exerciseLogId,
      Value<String> ruleId,
      Value<int> priority,
      Value<String> params,
    });

final class $$SuggestionsTableReferences
    extends BaseReferences<_$AppDatabase, $SuggestionsTable, Suggestion> {
  $$SuggestionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('suggestions__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExerciseLogsTable _exerciseLogIdTable(_$AppDatabase db) => db
      .exerciseLogs
      .createAlias('suggestions__exercise_log_id__exercise_logs__id');

  $$ExerciseLogsTableProcessedTableManager? get exerciseLogId {
    final $_column = $_itemColumn<int>('exercise_log_id');
    if ($_column == null) return null;
    final manager = $$ExerciseLogsTableTableManager(
      $_db,
      $_db.exerciseLogs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseLogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SuggestionsTableFilterComposer
    extends Composer<_$AppDatabase, $SuggestionsTable> {
  $$SuggestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get params => $composableBuilder(
    column: $table.params,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseLogsTableFilterComposer get exerciseLogId {
    final $$ExerciseLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseLogId,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SuggestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SuggestionsTable> {
  $$SuggestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get params => $composableBuilder(
    column: $table.params,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseLogsTableOrderingComposer get exerciseLogId {
    final $$ExerciseLogsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseLogId,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SuggestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuggestionsTable> {
  $$SuggestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get params =>
      $composableBuilder(column: $table.params, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExerciseLogsTableAnnotationComposer get exerciseLogId {
    final $$ExerciseLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseLogId,
      referencedTable: $db.exerciseLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SuggestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuggestionsTable,
          Suggestion,
          $$SuggestionsTableFilterComposer,
          $$SuggestionsTableOrderingComposer,
          $$SuggestionsTableAnnotationComposer,
          $$SuggestionsTableCreateCompanionBuilder,
          $$SuggestionsTableUpdateCompanionBuilder,
          (Suggestion, $$SuggestionsTableReferences),
          Suggestion,
          PrefetchHooks Function({bool sessionId, bool exerciseLogId})
        > {
  $$SuggestionsTableTableManager(_$AppDatabase db, $SuggestionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuggestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuggestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuggestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int?> exerciseLogId = const Value.absent(),
                Value<String> ruleId = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> params = const Value.absent(),
              }) => SuggestionsCompanion(
                id: id,
                sessionId: sessionId,
                exerciseLogId: exerciseLogId,
                ruleId: ruleId,
                priority: priority,
                params: params,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                Value<int?> exerciseLogId = const Value.absent(),
                required String ruleId,
                required int priority,
                Value<String> params = const Value.absent(),
              }) => SuggestionsCompanion.insert(
                id: id,
                sessionId: sessionId,
                exerciseLogId: exerciseLogId,
                ruleId: ruleId,
                priority: priority,
                params: params,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SuggestionsTable, Suggestion>(table),
                  $$SuggestionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, exerciseLogId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$SuggestionsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$SuggestionsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (exerciseLogId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseLogId,
                                referencedTable: $$SuggestionsTableReferences
                                    ._exerciseLogIdTable(db),
                                referencedColumn: $$SuggestionsTableReferences
                                    ._exerciseLogIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SuggestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuggestionsTable,
      Suggestion,
      $$SuggestionsTableFilterComposer,
      $$SuggestionsTableOrderingComposer,
      $$SuggestionsTableAnnotationComposer,
      $$SuggestionsTableCreateCompanionBuilder,
      $$SuggestionsTableUpdateCompanionBuilder,
      (Suggestion, $$SuggestionsTableReferences),
      Suggestion,
      PrefetchHooks Function({bool sessionId, bool exerciseLogId})
    >;
typedef $$StreakStatesTableCreateCompanionBuilder =
    StreakStatesCompanion Function({
      Value<int> id,
      Value<int> currentWeeks,
      Value<int> longestWeeks,
      Value<int> updatedAt,
    });
typedef $$StreakStatesTableUpdateCompanionBuilder =
    StreakStatesCompanion Function({
      Value<int> id,
      Value<int> currentWeeks,
      Value<int> longestWeeks,
      Value<int> updatedAt,
    });

class $$StreakStatesTableFilterComposer
    extends Composer<_$AppDatabase, $StreakStatesTable> {
  $$StreakStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentWeeks => $composableBuilder(
    column: $table.currentWeeks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestWeeks => $composableBuilder(
    column: $table.longestWeeks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StreakStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $StreakStatesTable> {
  $$StreakStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentWeeks => $composableBuilder(
    column: $table.currentWeeks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestWeeks => $composableBuilder(
    column: $table.longestWeeks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StreakStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StreakStatesTable> {
  $$StreakStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get currentWeeks => $composableBuilder(
    column: $table.currentWeeks,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestWeeks => $composableBuilder(
    column: $table.longestWeeks,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StreakStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StreakStatesTable,
          StreakState,
          $$StreakStatesTableFilterComposer,
          $$StreakStatesTableOrderingComposer,
          $$StreakStatesTableAnnotationComposer,
          $$StreakStatesTableCreateCompanionBuilder,
          $$StreakStatesTableUpdateCompanionBuilder,
          (
            StreakState,
            BaseReferences<_$AppDatabase, $StreakStatesTable, StreakState>,
          ),
          StreakState,
          PrefetchHooks Function()
        > {
  $$StreakStatesTableTableManager(_$AppDatabase db, $StreakStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreakStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreakStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreakStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> currentWeeks = const Value.absent(),
                Value<int> longestWeeks = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => StreakStatesCompanion(
                id: id,
                currentWeeks: currentWeeks,
                longestWeeks: longestWeeks,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> currentWeeks = const Value.absent(),
                Value<int> longestWeeks = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => StreakStatesCompanion.insert(
                id: id,
                currentWeeks: currentWeeks,
                longestWeeks: longestWeeks,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StreakStatesTable, StreakState>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $StreakStatesTable,
                    StreakState
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StreakStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StreakStatesTable,
      StreakState,
      $$StreakStatesTableFilterComposer,
      $$StreakStatesTableOrderingComposer,
      $$StreakStatesTableAnnotationComposer,
      $$StreakStatesTableCreateCompanionBuilder,
      $$StreakStatesTableUpdateCompanionBuilder,
      (
        StreakState,
        BaseReferences<_$AppDatabase, $StreakStatesTable, StreakState>,
      ),
      StreakState,
      PrefetchHooks Function()
    >;
typedef $$NutritionDaysTableCreateCompanionBuilder =
    NutritionDaysCompanion Function({
      Value<int> day,
      Value<int?> calories,
      Value<int?> protein,
    });
typedef $$NutritionDaysTableUpdateCompanionBuilder =
    NutritionDaysCompanion Function({
      Value<int> day,
      Value<int?> calories,
      Value<int?> protein,
    });

class $$NutritionDaysTableFilterComposer
    extends Composer<_$AppDatabase, $NutritionDaysTable> {
  $$NutritionDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NutritionDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $NutritionDaysTable> {
  $$NutritionDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NutritionDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $NutritionDaysTable> {
  $$NutritionDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<int> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);
}

class $$NutritionDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NutritionDaysTable,
          NutritionDay,
          $$NutritionDaysTableFilterComposer,
          $$NutritionDaysTableOrderingComposer,
          $$NutritionDaysTableAnnotationComposer,
          $$NutritionDaysTableCreateCompanionBuilder,
          $$NutritionDaysTableUpdateCompanionBuilder,
          (
            NutritionDay,
            BaseReferences<_$AppDatabase, $NutritionDaysTable, NutritionDay>,
          ),
          NutritionDay,
          PrefetchHooks Function()
        > {
  $$NutritionDaysTableTableManager(_$AppDatabase db, $NutritionDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutritionDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutritionDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NutritionDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> day = const Value.absent(),
                Value<int?> calories = const Value.absent(),
                Value<int?> protein = const Value.absent(),
              }) => NutritionDaysCompanion(
                day: day,
                calories: calories,
                protein: protein,
              ),
          createCompanionCallback:
              ({
                Value<int> day = const Value.absent(),
                Value<int?> calories = const Value.absent(),
                Value<int?> protein = const Value.absent(),
              }) => NutritionDaysCompanion.insert(
                day: day,
                calories: calories,
                protein: protein,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NutritionDaysTable, NutritionDay>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $NutritionDaysTable,
                    NutritionDay
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NutritionDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NutritionDaysTable,
      NutritionDay,
      $$NutritionDaysTableFilterComposer,
      $$NutritionDaysTableOrderingComposer,
      $$NutritionDaysTableAnnotationComposer,
      $$NutritionDaysTableCreateCompanionBuilder,
      $$NutritionDaysTableUpdateCompanionBuilder,
      (
        NutritionDay,
        BaseReferences<_$AppDatabase, $NutritionDaysTable, NutritionDay>,
      ),
      NutritionDay,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProgramsTableTableManager get programs =>
      $$ProgramsTableTableManager(_db, _db.programs);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$ExerciseLogsTableTableManager get exerciseLogs =>
      $$ExerciseLogsTableTableManager(_db, _db.exerciseLogs);
  $$SetEntriesTableTableManager get setEntries =>
      $$SetEntriesTableTableManager(_db, _db.setEntries);
  $$DaySummariesTableTableManager get daySummaries =>
      $$DaySummariesTableTableManager(_db, _db.daySummaries);
  $$WeekSummariesTableTableManager get weekSummaries =>
      $$WeekSummariesTableTableManager(_db, _db.weekSummaries);
  $$ExerciseStatsTableTableManager get exerciseStats =>
      $$ExerciseStatsTableTableManager(_db, _db.exerciseStats);
  $$SuggestionsTableTableManager get suggestions =>
      $$SuggestionsTableTableManager(_db, _db.suggestions);
  $$StreakStatesTableTableManager get streakStates =>
      $$StreakStatesTableTableManager(_db, _db.streakStates);
  $$NutritionDaysTableTableManager get nutritionDays =>
      $$NutritionDaysTableTableManager(_db, _db.nutritionDays);
}
