// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalProjectsTable extends LocalProjects
    with TableInfo<$LocalProjectsTable, LocalProject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _netValueMeta = const VerificationMeta(
    'netValue',
  );
  @override
  late final GeneratedColumn<double> netValue = GeneratedColumn<double>(
    'net_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _taxPercentMeta = const VerificationMeta(
    'taxPercent',
  );
  @override
  late final GeneratedColumn<double> taxPercent = GeneratedColumn<double>(
    'tax_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalValueMeta = const VerificationMeta(
    'totalValue',
  );
  @override
  late final GeneratedColumn<double> totalValue = GeneratedColumn<double>(
    'total_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    title,
    description,
    customerId,
    status,
    netValue,
    taxPercent,
    totalValue,
    notes,
    address,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalProject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('net_value')) {
      context.handle(
        _netValueMeta,
        netValue.isAcceptableOrUnknown(data['net_value']!, _netValueMeta),
      );
    }
    if (data.containsKey('tax_percent')) {
      context.handle(
        _taxPercentMeta,
        taxPercent.isAcceptableOrUnknown(data['tax_percent']!, _taxPercentMeta),
      );
    }
    if (data.containsKey('total_value')) {
      context.handle(
        _totalValueMeta,
        totalValue.isAcceptableOrUnknown(data['total_value']!, _totalValueMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalProject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      netValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}net_value'],
      )!,
      taxPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_percent'],
      )!,
      totalValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_value'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
    );
  }

  @override
  $LocalProjectsTable createAlias(String alias) {
    return $LocalProjectsTable(attachedDatabase, alias);
  }
}

class LocalProject extends DataClass implements Insertable<LocalProject> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String? description;
  final String? customerId;
  final String status;
  final double netValue;
  final double taxPercent;
  final double totalValue;
  final String? notes;
  final String? address;
  const LocalProject({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    this.description,
    this.customerId,
    required this.status,
    required this.netValue,
    required this.taxPercent,
    required this.totalValue,
    this.notes,
    this.address,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['status'] = Variable<String>(status);
    map['net_value'] = Variable<double>(netValue);
    map['tax_percent'] = Variable<double>(taxPercent);
    map['total_value'] = Variable<double>(totalValue);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    return map;
  }

  LocalProjectsCompanion toCompanion(bool nullToAbsent) {
    return LocalProjectsCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      status: Value(status),
      netValue: Value(netValue),
      taxPercent: Value(taxPercent),
      totalValue: Value(totalValue),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
    );
  }

  factory LocalProject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProject(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      status: serializer.fromJson<String>(json['status']),
      netValue: serializer.fromJson<double>(json['netValue']),
      taxPercent: serializer.fromJson<double>(json['taxPercent']),
      totalValue: serializer.fromJson<double>(json['totalValue']),
      notes: serializer.fromJson<String?>(json['notes']),
      address: serializer.fromJson<String?>(json['address']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'customerId': serializer.toJson<String?>(customerId),
      'status': serializer.toJson<String>(status),
      'netValue': serializer.toJson<double>(netValue),
      'taxPercent': serializer.toJson<double>(taxPercent),
      'totalValue': serializer.toJson<double>(totalValue),
      'notes': serializer.toJson<String?>(notes),
      'address': serializer.toJson<String?>(address),
    };
  }

  LocalProject copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> customerId = const Value.absent(),
    String? status,
    double? netValue,
    double? taxPercent,
    double? totalValue,
    Value<String?> notes = const Value.absent(),
    Value<String?> address = const Value.absent(),
  }) => LocalProject(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    customerId: customerId.present ? customerId.value : this.customerId,
    status: status ?? this.status,
    netValue: netValue ?? this.netValue,
    taxPercent: taxPercent ?? this.taxPercent,
    totalValue: totalValue ?? this.totalValue,
    notes: notes.present ? notes.value : this.notes,
    address: address.present ? address.value : this.address,
  );
  LocalProject copyWithCompanion(LocalProjectsCompanion data) {
    return LocalProject(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      status: data.status.present ? data.status.value : this.status,
      netValue: data.netValue.present ? data.netValue.value : this.netValue,
      taxPercent: data.taxPercent.present
          ? data.taxPercent.value
          : this.taxPercent,
      totalValue: data.totalValue.present
          ? data.totalValue.value
          : this.totalValue,
      notes: data.notes.present ? data.notes.value : this.notes,
      address: data.address.present ? data.address.value : this.address,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProject(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('customerId: $customerId, ')
          ..write('status: $status, ')
          ..write('netValue: $netValue, ')
          ..write('taxPercent: $taxPercent, ')
          ..write('totalValue: $totalValue, ')
          ..write('notes: $notes, ')
          ..write('address: $address')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    title,
    description,
    customerId,
    status,
    netValue,
    taxPercent,
    totalValue,
    notes,
    address,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProject &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.title == this.title &&
          other.description == this.description &&
          other.customerId == this.customerId &&
          other.status == this.status &&
          other.netValue == this.netValue &&
          other.taxPercent == this.taxPercent &&
          other.totalValue == this.totalValue &&
          other.notes == this.notes &&
          other.address == this.address);
}

class LocalProjectsCompanion extends UpdateCompanion<LocalProject> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> customerId;
  final Value<String> status;
  final Value<double> netValue;
  final Value<double> taxPercent;
  final Value<double> totalValue;
  final Value<String?> notes;
  final Value<String?> address;
  final Value<int> rowid;
  const LocalProjectsCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.customerId = const Value.absent(),
    this.status = const Value.absent(),
    this.netValue = const Value.absent(),
    this.taxPercent = const Value.absent(),
    this.totalValue = const Value.absent(),
    this.notes = const Value.absent(),
    this.address = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProjectsCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.customerId = const Value.absent(),
    this.status = const Value.absent(),
    this.netValue = const Value.absent(),
    this.taxPercent = const Value.absent(),
    this.totalValue = const Value.absent(),
    this.notes = const Value.absent(),
    this.address = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : title = Value(title);
  static Insertable<LocalProject> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? customerId,
    Expression<String>? status,
    Expression<double>? netValue,
    Expression<double>? taxPercent,
    Expression<double>? totalValue,
    Expression<String>? notes,
    Expression<String>? address,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (customerId != null) 'customer_id': customerId,
      if (status != null) 'status': status,
      if (netValue != null) 'net_value': netValue,
      if (taxPercent != null) 'tax_percent': taxPercent,
      if (totalValue != null) 'total_value': totalValue,
      if (notes != null) 'notes': notes,
      if (address != null) 'address': address,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? customerId,
    Value<String>? status,
    Value<double>? netValue,
    Value<double>? taxPercent,
    Value<double>? totalValue,
    Value<String?>? notes,
    Value<String?>? address,
    Value<int>? rowid,
  }) {
    return LocalProjectsCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      description: description ?? this.description,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      netValue: netValue ?? this.netValue,
      taxPercent: taxPercent ?? this.taxPercent,
      totalValue: totalValue ?? this.totalValue,
      notes: notes ?? this.notes,
      address: address ?? this.address,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (netValue.present) {
      map['net_value'] = Variable<double>(netValue.value);
    }
    if (taxPercent.present) {
      map['tax_percent'] = Variable<double>(taxPercent.value);
    }
    if (totalValue.present) {
      map['total_value'] = Variable<double>(totalValue.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProjectsCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('customerId: $customerId, ')
          ..write('status: $status, ')
          ..write('netValue: $netValue, ')
          ..write('taxPercent: $taxPercent, ')
          ..write('totalValue: $totalValue, ')
          ..write('notes: $notes, ')
          ..write('address: $address, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMeasurementSessionsTable extends LocalMeasurementSessions
    with TableInfo<$LocalMeasurementSessionsTable, LocalMeasurementSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMeasurementSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _technicianIdMeta = const VerificationMeta(
    'technicianId',
  );
  @override
  late final GeneratedColumn<String> technicianId = GeneratedColumn<String>(
    'technician_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('in_progress'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    projectId,
    technicianId,
    status,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_measurement_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMeasurementSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('technician_id')) {
      context.handle(
        _technicianIdMeta,
        technicianId.isAcceptableOrUnknown(
          data['technician_id']!,
          _technicianIdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMeasurementSession map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMeasurementSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      technicianId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}technician_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $LocalMeasurementSessionsTable createAlias(String alias) {
    return $LocalMeasurementSessionsTable(attachedDatabase, alias);
  }
}

class LocalMeasurementSession extends DataClass
    implements Insertable<LocalMeasurementSession> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String projectId;
  final String? technicianId;
  final String status;
  final String? notes;
  const LocalMeasurementSession({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.projectId,
    this.technicianId,
    required this.status,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['project_id'] = Variable<String>(projectId);
    if (!nullToAbsent || technicianId != null) {
      map['technician_id'] = Variable<String>(technicianId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  LocalMeasurementSessionsCompanion toCompanion(bool nullToAbsent) {
    return LocalMeasurementSessionsCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      projectId: Value(projectId),
      technicianId: technicianId == null && nullToAbsent
          ? const Value.absent()
          : Value(technicianId),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory LocalMeasurementSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMeasurementSession(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      projectId: serializer.fromJson<String>(json['projectId']),
      technicianId: serializer.fromJson<String?>(json['technicianId']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'projectId': serializer.toJson<String>(projectId),
      'technicianId': serializer.toJson<String?>(technicianId),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LocalMeasurementSession copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? projectId,
    Value<String?> technicianId = const Value.absent(),
    String? status,
    Value<String?> notes = const Value.absent(),
  }) => LocalMeasurementSession(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    projectId: projectId ?? this.projectId,
    technicianId: technicianId.present ? technicianId.value : this.technicianId,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
  );
  LocalMeasurementSession copyWithCompanion(
    LocalMeasurementSessionsCompanion data,
  ) {
    return LocalMeasurementSession(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      technicianId: data.technicianId.present
          ? data.technicianId.value
          : this.technicianId,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMeasurementSession(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('projectId: $projectId, ')
          ..write('technicianId: $technicianId, ')
          ..write('status: $status, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    projectId,
    technicianId,
    status,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMeasurementSession &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.projectId == this.projectId &&
          other.technicianId == this.technicianId &&
          other.status == this.status &&
          other.notes == this.notes);
}

class LocalMeasurementSessionsCompanion
    extends UpdateCompanion<LocalMeasurementSession> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> projectId;
  final Value<String?> technicianId;
  final Value<String> status;
  final Value<String?> notes;
  final Value<int> rowid;
  const LocalMeasurementSessionsCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.projectId = const Value.absent(),
    this.technicianId = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMeasurementSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String projectId,
    this.technicianId = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : projectId = Value(projectId);
  static Insertable<LocalMeasurementSession> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? projectId,
    Expression<String>? technicianId,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (projectId != null) 'project_id': projectId,
      if (technicianId != null) 'technician_id': technicianId,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMeasurementSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? projectId,
    Value<String?>? technicianId,
    Value<String>? status,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return LocalMeasurementSessionsCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      projectId: projectId ?? this.projectId,
      technicianId: technicianId ?? this.technicianId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (technicianId.present) {
      map['technician_id'] = Variable<String>(technicianId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMeasurementSessionsCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('projectId: $projectId, ')
          ..write('technicianId: $technicianId, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalRoomsTable extends LocalRooms
    with TableInfo<$LocalRoomsTable, LocalRoom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lengthMeta = const VerificationMeta('length');
  @override
  late final GeneratedColumn<double> length = GeneratedColumn<double>(
    'length',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _floorAreaMeta = const VerificationMeta(
    'floorArea',
  );
  @override
  late final GeneratedColumn<double> floorArea = GeneratedColumn<double>(
    'floor_area',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _perimeterMeta = const VerificationMeta(
    'perimeter',
  );
  @override
  late final GeneratedColumn<double> perimeter = GeneratedColumn<double>(
    'perimeter',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    sessionId,
    name,
    type,
    length,
    width,
    height,
    floorArea,
    perimeter,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalRoom> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('length')) {
      context.handle(
        _lengthMeta,
        length.isAcceptableOrUnknown(data['length']!, _lengthMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('floor_area')) {
      context.handle(
        _floorAreaMeta,
        floorArea.isAcceptableOrUnknown(data['floor_area']!, _floorAreaMeta),
      );
    }
    if (data.containsKey('perimeter')) {
      context.handle(
        _perimeterMeta,
        perimeter.isAcceptableOrUnknown(data['perimeter']!, _perimeterMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalRoom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRoom(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      length: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      )!,
      floorArea: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}floor_area'],
      )!,
      perimeter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}perimeter'],
      )!,
    );
  }

  @override
  $LocalRoomsTable createAlias(String alias) {
    return $LocalRoomsTable(attachedDatabase, alias);
  }
}

class LocalRoom extends DataClass implements Insertable<LocalRoom> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String sessionId;
  final String name;
  final String? type;
  final double length;
  final double width;
  final double height;
  final double floorArea;
  final double perimeter;
  const LocalRoom({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.sessionId,
    required this.name,
    this.type,
    required this.length,
    required this.width,
    required this.height,
    required this.floorArea,
    required this.perimeter,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['session_id'] = Variable<String>(sessionId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    map['length'] = Variable<double>(length);
    map['width'] = Variable<double>(width);
    map['height'] = Variable<double>(height);
    map['floor_area'] = Variable<double>(floorArea);
    map['perimeter'] = Variable<double>(perimeter);
    return map;
  }

  LocalRoomsCompanion toCompanion(bool nullToAbsent) {
    return LocalRoomsCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      sessionId: Value(sessionId),
      name: Value(name),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      length: Value(length),
      width: Value(width),
      height: Value(height),
      floorArea: Value(floorArea),
      perimeter: Value(perimeter),
    );
  }

  factory LocalRoom.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRoom(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String?>(json['type']),
      length: serializer.fromJson<double>(json['length']),
      width: serializer.fromJson<double>(json['width']),
      height: serializer.fromJson<double>(json['height']),
      floorArea: serializer.fromJson<double>(json['floorArea']),
      perimeter: serializer.fromJson<double>(json['perimeter']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sessionId': serializer.toJson<String>(sessionId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String?>(type),
      'length': serializer.toJson<double>(length),
      'width': serializer.toJson<double>(width),
      'height': serializer.toJson<double>(height),
      'floorArea': serializer.toJson<double>(floorArea),
      'perimeter': serializer.toJson<double>(perimeter),
    };
  }

  LocalRoom copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sessionId,
    String? name,
    Value<String?> type = const Value.absent(),
    double? length,
    double? width,
    double? height,
    double? floorArea,
    double? perimeter,
  }) => LocalRoom(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    sessionId: sessionId ?? this.sessionId,
    name: name ?? this.name,
    type: type.present ? type.value : this.type,
    length: length ?? this.length,
    width: width ?? this.width,
    height: height ?? this.height,
    floorArea: floorArea ?? this.floorArea,
    perimeter: perimeter ?? this.perimeter,
  );
  LocalRoom copyWithCompanion(LocalRoomsCompanion data) {
    return LocalRoom(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      length: data.length.present ? data.length.value : this.length,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      floorArea: data.floorArea.present ? data.floorArea.value : this.floorArea,
      perimeter: data.perimeter.present ? data.perimeter.value : this.perimeter,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRoom(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('length: $length, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('floorArea: $floorArea, ')
          ..write('perimeter: $perimeter')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    sessionId,
    name,
    type,
    length,
    width,
    height,
    floorArea,
    perimeter,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRoom &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.sessionId == this.sessionId &&
          other.name == this.name &&
          other.type == this.type &&
          other.length == this.length &&
          other.width == this.width &&
          other.height == this.height &&
          other.floorArea == this.floorArea &&
          other.perimeter == this.perimeter);
}

class LocalRoomsCompanion extends UpdateCompanion<LocalRoom> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> sessionId;
  final Value<String> name;
  final Value<String?> type;
  final Value<double> length;
  final Value<double> width;
  final Value<double> height;
  final Value<double> floorArea;
  final Value<double> perimeter;
  final Value<int> rowid;
  const LocalRoomsCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.length = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.floorArea = const Value.absent(),
    this.perimeter = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalRoomsCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String sessionId,
    required String name,
    this.type = const Value.absent(),
    this.length = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.floorArea = const Value.absent(),
    this.perimeter = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       name = Value(name);
  static Insertable<LocalRoom> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? sessionId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<double>? length,
    Expression<double>? width,
    Expression<double>? height,
    Expression<double>? floorArea,
    Expression<double>? perimeter,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sessionId != null) 'session_id': sessionId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (length != null) 'length': length,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (floorArea != null) 'floor_area': floorArea,
      if (perimeter != null) 'perimeter': perimeter,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalRoomsCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? sessionId,
    Value<String>? name,
    Value<String?>? type,
    Value<double>? length,
    Value<double>? width,
    Value<double>? height,
    Value<double>? floorArea,
    Value<double>? perimeter,
    Value<int>? rowid,
  }) {
    return LocalRoomsCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sessionId: sessionId ?? this.sessionId,
      name: name ?? this.name,
      type: type ?? this.type,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      floorArea: floorArea ?? this.floorArea,
      perimeter: perimeter ?? this.perimeter,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (length.present) {
      map['length'] = Variable<double>(length.value);
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (floorArea.present) {
      map['floor_area'] = Variable<double>(floorArea.value);
    }
    if (perimeter.present) {
      map['perimeter'] = Variable<double>(perimeter.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRoomsCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('length: $length, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('floorArea: $floorArea, ')
          ..write('perimeter: $perimeter, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalWallsTable extends LocalWalls
    with TableInfo<$LocalWallsTable, LocalWall> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalWallsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lengthMeta = const VerificationMeta('length');
  @override
  late final GeneratedColumn<double> length = GeneratedColumn<double>(
    'length',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _grossAreaMeta = const VerificationMeta(
    'grossArea',
  );
  @override
  late final GeneratedColumn<double> grossArea = GeneratedColumn<double>(
    'gross_area',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _netAreaMeta = const VerificationMeta(
    'netArea',
  );
  @override
  late final GeneratedColumn<double> netArea = GeneratedColumn<double>(
    'net_area',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _materialTypeMeta = const VerificationMeta(
    'materialType',
  );
  @override
  late final GeneratedColumn<String> materialType = GeneratedColumn<String>(
    'material_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    roomId,
    name,
    length,
    height,
    grossArea,
    netArea,
    materialType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_walls';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalWall> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('length')) {
      context.handle(
        _lengthMeta,
        length.isAcceptableOrUnknown(data['length']!, _lengthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('gross_area')) {
      context.handle(
        _grossAreaMeta,
        grossArea.isAcceptableOrUnknown(data['gross_area']!, _grossAreaMeta),
      );
    }
    if (data.containsKey('net_area')) {
      context.handle(
        _netAreaMeta,
        netArea.isAcceptableOrUnknown(data['net_area']!, _netAreaMeta),
      );
    }
    if (data.containsKey('material_type')) {
      context.handle(
        _materialTypeMeta,
        materialType.isAcceptableOrUnknown(
          data['material_type']!,
          _materialTypeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalWall map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalWall(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      length: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      )!,
      grossArea: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gross_area'],
      )!,
      netArea: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}net_area'],
      )!,
      materialType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material_type'],
      ),
    );
  }

  @override
  $LocalWallsTable createAlias(String alias) {
    return $LocalWallsTable(attachedDatabase, alias);
  }
}

class LocalWall extends DataClass implements Insertable<LocalWall> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String roomId;
  final String name;
  final double length;
  final double height;
  final double grossArea;
  final double netArea;
  final String? materialType;
  const LocalWall({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.roomId,
    required this.name,
    required this.length,
    required this.height,
    required this.grossArea,
    required this.netArea,
    this.materialType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['room_id'] = Variable<String>(roomId);
    map['name'] = Variable<String>(name);
    map['length'] = Variable<double>(length);
    map['height'] = Variable<double>(height);
    map['gross_area'] = Variable<double>(grossArea);
    map['net_area'] = Variable<double>(netArea);
    if (!nullToAbsent || materialType != null) {
      map['material_type'] = Variable<String>(materialType);
    }
    return map;
  }

  LocalWallsCompanion toCompanion(bool nullToAbsent) {
    return LocalWallsCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      roomId: Value(roomId),
      name: Value(name),
      length: Value(length),
      height: Value(height),
      grossArea: Value(grossArea),
      netArea: Value(netArea),
      materialType: materialType == null && nullToAbsent
          ? const Value.absent()
          : Value(materialType),
    );
  }

  factory LocalWall.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalWall(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      roomId: serializer.fromJson<String>(json['roomId']),
      name: serializer.fromJson<String>(json['name']),
      length: serializer.fromJson<double>(json['length']),
      height: serializer.fromJson<double>(json['height']),
      grossArea: serializer.fromJson<double>(json['grossArea']),
      netArea: serializer.fromJson<double>(json['netArea']),
      materialType: serializer.fromJson<String?>(json['materialType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'roomId': serializer.toJson<String>(roomId),
      'name': serializer.toJson<String>(name),
      'length': serializer.toJson<double>(length),
      'height': serializer.toJson<double>(height),
      'grossArea': serializer.toJson<double>(grossArea),
      'netArea': serializer.toJson<double>(netArea),
      'materialType': serializer.toJson<String?>(materialType),
    };
  }

  LocalWall copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? roomId,
    String? name,
    double? length,
    double? height,
    double? grossArea,
    double? netArea,
    Value<String?> materialType = const Value.absent(),
  }) => LocalWall(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    roomId: roomId ?? this.roomId,
    name: name ?? this.name,
    length: length ?? this.length,
    height: height ?? this.height,
    grossArea: grossArea ?? this.grossArea,
    netArea: netArea ?? this.netArea,
    materialType: materialType.present ? materialType.value : this.materialType,
  );
  LocalWall copyWithCompanion(LocalWallsCompanion data) {
    return LocalWall(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      name: data.name.present ? data.name.value : this.name,
      length: data.length.present ? data.length.value : this.length,
      height: data.height.present ? data.height.value : this.height,
      grossArea: data.grossArea.present ? data.grossArea.value : this.grossArea,
      netArea: data.netArea.present ? data.netArea.value : this.netArea,
      materialType: data.materialType.present
          ? data.materialType.value
          : this.materialType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalWall(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('roomId: $roomId, ')
          ..write('name: $name, ')
          ..write('length: $length, ')
          ..write('height: $height, ')
          ..write('grossArea: $grossArea, ')
          ..write('netArea: $netArea, ')
          ..write('materialType: $materialType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    roomId,
    name,
    length,
    height,
    grossArea,
    netArea,
    materialType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalWall &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.roomId == this.roomId &&
          other.name == this.name &&
          other.length == this.length &&
          other.height == this.height &&
          other.grossArea == this.grossArea &&
          other.netArea == this.netArea &&
          other.materialType == this.materialType);
}

class LocalWallsCompanion extends UpdateCompanion<LocalWall> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> roomId;
  final Value<String> name;
  final Value<double> length;
  final Value<double> height;
  final Value<double> grossArea;
  final Value<double> netArea;
  final Value<String?> materialType;
  final Value<int> rowid;
  const LocalWallsCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.roomId = const Value.absent(),
    this.name = const Value.absent(),
    this.length = const Value.absent(),
    this.height = const Value.absent(),
    this.grossArea = const Value.absent(),
    this.netArea = const Value.absent(),
    this.materialType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalWallsCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String roomId,
    required String name,
    this.length = const Value.absent(),
    this.height = const Value.absent(),
    this.grossArea = const Value.absent(),
    this.netArea = const Value.absent(),
    this.materialType = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : roomId = Value(roomId),
       name = Value(name);
  static Insertable<LocalWall> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? roomId,
    Expression<String>? name,
    Expression<double>? length,
    Expression<double>? height,
    Expression<double>? grossArea,
    Expression<double>? netArea,
    Expression<String>? materialType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (roomId != null) 'room_id': roomId,
      if (name != null) 'name': name,
      if (length != null) 'length': length,
      if (height != null) 'height': height,
      if (grossArea != null) 'gross_area': grossArea,
      if (netArea != null) 'net_area': netArea,
      if (materialType != null) 'material_type': materialType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalWallsCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? roomId,
    Value<String>? name,
    Value<double>? length,
    Value<double>? height,
    Value<double>? grossArea,
    Value<double>? netArea,
    Value<String?>? materialType,
    Value<int>? rowid,
  }) {
    return LocalWallsCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      length: length ?? this.length,
      height: height ?? this.height,
      grossArea: grossArea ?? this.grossArea,
      netArea: netArea ?? this.netArea,
      materialType: materialType ?? this.materialType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (length.present) {
      map['length'] = Variable<double>(length.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (grossArea.present) {
      map['gross_area'] = Variable<double>(grossArea.value);
    }
    if (netArea.present) {
      map['net_area'] = Variable<double>(netArea.value);
    }
    if (materialType.present) {
      map['material_type'] = Variable<String>(materialType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalWallsCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('roomId: $roomId, ')
          ..write('name: $name, ')
          ..write('length: $length, ')
          ..write('height: $height, ')
          ..write('grossArea: $grossArea, ')
          ..write('netArea: $netArea, ')
          ..write('materialType: $materialType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalWallOpeningsTable extends LocalWallOpenings
    with TableInfo<$LocalWallOpeningsTable, LocalWallOpening> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalWallOpeningsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _wallIdMeta = const VerificationMeta('wallId');
  @override
  late final GeneratedColumn<String> wallId = GeneratedColumn<String>(
    'wall_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _areaMeta = const VerificationMeta('area');
  @override
  late final GeneratedColumn<double> area = GeneratedColumn<double>(
    'area',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _deductFromWallMeta = const VerificationMeta(
    'deductFromWall',
  );
  @override
  late final GeneratedColumn<bool> deductFromWall = GeneratedColumn<bool>(
    'deduct_from_wall',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deduct_from_wall" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    wallId,
    type,
    name,
    width,
    height,
    area,
    deductFromWall,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_wall_openings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalWallOpening> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('wall_id')) {
      context.handle(
        _wallIdMeta,
        wallId.isAcceptableOrUnknown(data['wall_id']!, _wallIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wallIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('area')) {
      context.handle(
        _areaMeta,
        area.isAcceptableOrUnknown(data['area']!, _areaMeta),
      );
    }
    if (data.containsKey('deduct_from_wall')) {
      context.handle(
        _deductFromWallMeta,
        deductFromWall.isAcceptableOrUnknown(
          data['deduct_from_wall']!,
          _deductFromWallMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalWallOpening map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalWallOpening(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      wallId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wall_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      )!,
      area: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area'],
      )!,
      deductFromWall: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deduct_from_wall'],
      )!,
    );
  }

  @override
  $LocalWallOpeningsTable createAlias(String alias) {
    return $LocalWallOpeningsTable(attachedDatabase, alias);
  }
}

class LocalWallOpening extends DataClass
    implements Insertable<LocalWallOpening> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String wallId;
  final String type;
  final String? name;
  final double width;
  final double height;
  final double area;
  final bool deductFromWall;
  const LocalWallOpening({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.wallId,
    required this.type,
    this.name,
    required this.width,
    required this.height,
    required this.area,
    required this.deductFromWall,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['wall_id'] = Variable<String>(wallId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['width'] = Variable<double>(width);
    map['height'] = Variable<double>(height);
    map['area'] = Variable<double>(area);
    map['deduct_from_wall'] = Variable<bool>(deductFromWall);
    return map;
  }

  LocalWallOpeningsCompanion toCompanion(bool nullToAbsent) {
    return LocalWallOpeningsCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      wallId: Value(wallId),
      type: Value(type),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      width: Value(width),
      height: Value(height),
      area: Value(area),
      deductFromWall: Value(deductFromWall),
    );
  }

  factory LocalWallOpening.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalWallOpening(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      wallId: serializer.fromJson<String>(json['wallId']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String?>(json['name']),
      width: serializer.fromJson<double>(json['width']),
      height: serializer.fromJson<double>(json['height']),
      area: serializer.fromJson<double>(json['area']),
      deductFromWall: serializer.fromJson<bool>(json['deductFromWall']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'wallId': serializer.toJson<String>(wallId),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String?>(name),
      'width': serializer.toJson<double>(width),
      'height': serializer.toJson<double>(height),
      'area': serializer.toJson<double>(area),
      'deductFromWall': serializer.toJson<bool>(deductFromWall),
    };
  }

  LocalWallOpening copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? wallId,
    String? type,
    Value<String?> name = const Value.absent(),
    double? width,
    double? height,
    double? area,
    bool? deductFromWall,
  }) => LocalWallOpening(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    wallId: wallId ?? this.wallId,
    type: type ?? this.type,
    name: name.present ? name.value : this.name,
    width: width ?? this.width,
    height: height ?? this.height,
    area: area ?? this.area,
    deductFromWall: deductFromWall ?? this.deductFromWall,
  );
  LocalWallOpening copyWithCompanion(LocalWallOpeningsCompanion data) {
    return LocalWallOpening(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      wallId: data.wallId.present ? data.wallId.value : this.wallId,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      area: data.area.present ? data.area.value : this.area,
      deductFromWall: data.deductFromWall.present
          ? data.deductFromWall.value
          : this.deductFromWall,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalWallOpening(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('wallId: $wallId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('area: $area, ')
          ..write('deductFromWall: $deductFromWall')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    wallId,
    type,
    name,
    width,
    height,
    area,
    deductFromWall,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalWallOpening &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.wallId == this.wallId &&
          other.type == this.type &&
          other.name == this.name &&
          other.width == this.width &&
          other.height == this.height &&
          other.area == this.area &&
          other.deductFromWall == this.deductFromWall);
}

class LocalWallOpeningsCompanion extends UpdateCompanion<LocalWallOpening> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> wallId;
  final Value<String> type;
  final Value<String?> name;
  final Value<double> width;
  final Value<double> height;
  final Value<double> area;
  final Value<bool> deductFromWall;
  final Value<int> rowid;
  const LocalWallOpeningsCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.wallId = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.area = const Value.absent(),
    this.deductFromWall = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalWallOpeningsCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String wallId,
    required String type,
    this.name = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.area = const Value.absent(),
    this.deductFromWall = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : wallId = Value(wallId),
       type = Value(type);
  static Insertable<LocalWallOpening> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? wallId,
    Expression<String>? type,
    Expression<String>? name,
    Expression<double>? width,
    Expression<double>? height,
    Expression<double>? area,
    Expression<bool>? deductFromWall,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (wallId != null) 'wall_id': wallId,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (area != null) 'area': area,
      if (deductFromWall != null) 'deduct_from_wall': deductFromWall,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalWallOpeningsCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? wallId,
    Value<String>? type,
    Value<String?>? name,
    Value<double>? width,
    Value<double>? height,
    Value<double>? area,
    Value<bool>? deductFromWall,
    Value<int>? rowid,
  }) {
    return LocalWallOpeningsCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      wallId: wallId ?? this.wallId,
      type: type ?? this.type,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      area: area ?? this.area,
      deductFromWall: deductFromWall ?? this.deductFromWall,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (wallId.present) {
      map['wall_id'] = Variable<String>(wallId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (area.present) {
      map['area'] = Variable<double>(area.value);
    }
    if (deductFromWall.present) {
      map['deduct_from_wall'] = Variable<bool>(deductFromWall.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalWallOpeningsCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('wallId: $wallId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('area: $area, ')
          ..write('deductFromWall: $deductFromWall, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalProductsTable extends LocalProducts
    with TableInfo<$LocalProductsTable, LocalProduct> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subcategoryMeta = const VerificationMeta(
    'subcategory',
  );
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
    'subcategory',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitTypeMeta = const VerificationMeta(
    'unitType',
  );
  @override
  late final GeneratedColumn<String> unitType = GeneratedColumn<String>(
    'unit_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _materialMeta = const VerificationMeta(
    'material',
  );
  @override
  late final GeneratedColumn<String> material = GeneratedColumn<String>(
    'material',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moistureResistanceMeta =
      const VerificationMeta('moistureResistance');
  @override
  late final GeneratedColumn<String> moistureResistance =
      GeneratedColumn<String>(
        'moisture_resistance',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _installationMethodMeta =
      const VerificationMeta('installationMethod');
  @override
  late final GeneratedColumn<String> installationMethod =
      GeneratedColumn<String>(
        'installation_method',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _defaultSupplierIdMeta = const VerificationMeta(
    'defaultSupplierId',
  );
  @override
  late final GeneratedColumn<String> defaultSupplierId =
      GeneratedColumn<String>(
        'default_supplier_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    name,
    code,
    category,
    subcategory,
    unitType,
    imageUrl,
    notes,
    isActive,
    brand,
    material,
    moistureResistance,
    installationMethod,
    defaultSupplierId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_products';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalProduct> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('subcategory')) {
      context.handle(
        _subcategoryMeta,
        subcategory.isAcceptableOrUnknown(
          data['subcategory']!,
          _subcategoryMeta,
        ),
      );
    }
    if (data.containsKey('unit_type')) {
      context.handle(
        _unitTypeMeta,
        unitType.isAcceptableOrUnknown(data['unit_type']!, _unitTypeMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('material')) {
      context.handle(
        _materialMeta,
        material.isAcceptableOrUnknown(data['material']!, _materialMeta),
      );
    }
    if (data.containsKey('moisture_resistance')) {
      context.handle(
        _moistureResistanceMeta,
        moistureResistance.isAcceptableOrUnknown(
          data['moisture_resistance']!,
          _moistureResistanceMeta,
        ),
      );
    }
    if (data.containsKey('installation_method')) {
      context.handle(
        _installationMethodMeta,
        installationMethod.isAcceptableOrUnknown(
          data['installation_method']!,
          _installationMethodMeta,
        ),
      );
    }
    if (data.containsKey('default_supplier_id')) {
      context.handle(
        _defaultSupplierIdMeta,
        defaultSupplierId.isAcceptableOrUnknown(
          data['default_supplier_id']!,
          _defaultSupplierIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalProduct map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProduct(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      subcategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subcategory'],
      ),
      unitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_type'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      material: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material'],
      ),
      moistureResistance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moisture_resistance'],
      ),
      installationMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_method'],
      ),
      defaultSupplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_supplier_id'],
      ),
    );
  }

  @override
  $LocalProductsTable createAlias(String alias) {
    return $LocalProductsTable(attachedDatabase, alias);
  }
}

class LocalProduct extends DataClass implements Insertable<LocalProduct> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final String? code;
  final String category;
  final String? subcategory;
  final String? unitType;
  final String? imageUrl;
  final String? notes;
  final bool isActive;
  final String? brand;
  final String? material;
  final String? moistureResistance;
  final String? installationMethod;
  final String? defaultSupplierId;
  const LocalProduct({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    this.code,
    required this.category,
    this.subcategory,
    this.unitType,
    this.imageUrl,
    this.notes,
    required this.isActive,
    this.brand,
    this.material,
    this.moistureResistance,
    this.installationMethod,
    this.defaultSupplierId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || subcategory != null) {
      map['subcategory'] = Variable<String>(subcategory);
    }
    if (!nullToAbsent || unitType != null) {
      map['unit_type'] = Variable<String>(unitType);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || material != null) {
      map['material'] = Variable<String>(material);
    }
    if (!nullToAbsent || moistureResistance != null) {
      map['moisture_resistance'] = Variable<String>(moistureResistance);
    }
    if (!nullToAbsent || installationMethod != null) {
      map['installation_method'] = Variable<String>(installationMethod);
    }
    if (!nullToAbsent || defaultSupplierId != null) {
      map['default_supplier_id'] = Variable<String>(defaultSupplierId);
    }
    return map;
  }

  LocalProductsCompanion toCompanion(bool nullToAbsent) {
    return LocalProductsCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      name: Value(name),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      category: Value(category),
      subcategory: subcategory == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategory),
      unitType: unitType == null && nullToAbsent
          ? const Value.absent()
          : Value(unitType),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isActive: Value(isActive),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      material: material == null && nullToAbsent
          ? const Value.absent()
          : Value(material),
      moistureResistance: moistureResistance == null && nullToAbsent
          ? const Value.absent()
          : Value(moistureResistance),
      installationMethod: installationMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(installationMethod),
      defaultSupplierId: defaultSupplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultSupplierId),
    );
  }

  factory LocalProduct.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProduct(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String?>(json['code']),
      category: serializer.fromJson<String>(json['category']),
      subcategory: serializer.fromJson<String?>(json['subcategory']),
      unitType: serializer.fromJson<String?>(json['unitType']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      brand: serializer.fromJson<String?>(json['brand']),
      material: serializer.fromJson<String?>(json['material']),
      moistureResistance: serializer.fromJson<String?>(
        json['moistureResistance'],
      ),
      installationMethod: serializer.fromJson<String?>(
        json['installationMethod'],
      ),
      defaultSupplierId: serializer.fromJson<String?>(
        json['defaultSupplierId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String?>(code),
      'category': serializer.toJson<String>(category),
      'subcategory': serializer.toJson<String?>(subcategory),
      'unitType': serializer.toJson<String?>(unitType),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'brand': serializer.toJson<String?>(brand),
      'material': serializer.toJson<String?>(material),
      'moistureResistance': serializer.toJson<String?>(moistureResistance),
      'installationMethod': serializer.toJson<String?>(installationMethod),
      'defaultSupplierId': serializer.toJson<String?>(defaultSupplierId),
    };
  }

  LocalProduct copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    Value<String?> code = const Value.absent(),
    String? category,
    Value<String?> subcategory = const Value.absent(),
    Value<String?> unitType = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isActive,
    Value<String?> brand = const Value.absent(),
    Value<String?> material = const Value.absent(),
    Value<String?> moistureResistance = const Value.absent(),
    Value<String?> installationMethod = const Value.absent(),
    Value<String?> defaultSupplierId = const Value.absent(),
  }) => LocalProduct(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    name: name ?? this.name,
    code: code.present ? code.value : this.code,
    category: category ?? this.category,
    subcategory: subcategory.present ? subcategory.value : this.subcategory,
    unitType: unitType.present ? unitType.value : this.unitType,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
    brand: brand.present ? brand.value : this.brand,
    material: material.present ? material.value : this.material,
    moistureResistance: moistureResistance.present
        ? moistureResistance.value
        : this.moistureResistance,
    installationMethod: installationMethod.present
        ? installationMethod.value
        : this.installationMethod,
    defaultSupplierId: defaultSupplierId.present
        ? defaultSupplierId.value
        : this.defaultSupplierId,
  );
  LocalProduct copyWithCompanion(LocalProductsCompanion data) {
    return LocalProduct(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      category: data.category.present ? data.category.value : this.category,
      subcategory: data.subcategory.present
          ? data.subcategory.value
          : this.subcategory,
      unitType: data.unitType.present ? data.unitType.value : this.unitType,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      brand: data.brand.present ? data.brand.value : this.brand,
      material: data.material.present ? data.material.value : this.material,
      moistureResistance: data.moistureResistance.present
          ? data.moistureResistance.value
          : this.moistureResistance,
      installationMethod: data.installationMethod.present
          ? data.installationMethod.value
          : this.installationMethod,
      defaultSupplierId: data.defaultSupplierId.present
          ? data.defaultSupplierId.value
          : this.defaultSupplierId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProduct(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('unitType: $unitType, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('brand: $brand, ')
          ..write('material: $material, ')
          ..write('moistureResistance: $moistureResistance, ')
          ..write('installationMethod: $installationMethod, ')
          ..write('defaultSupplierId: $defaultSupplierId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    name,
    code,
    category,
    subcategory,
    unitType,
    imageUrl,
    notes,
    isActive,
    brand,
    material,
    moistureResistance,
    installationMethod,
    defaultSupplierId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProduct &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.name == this.name &&
          other.code == this.code &&
          other.category == this.category &&
          other.subcategory == this.subcategory &&
          other.unitType == this.unitType &&
          other.imageUrl == this.imageUrl &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.brand == this.brand &&
          other.material == this.material &&
          other.moistureResistance == this.moistureResistance &&
          other.installationMethod == this.installationMethod &&
          other.defaultSupplierId == this.defaultSupplierId);
}

class LocalProductsCompanion extends UpdateCompanion<LocalProduct> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> name;
  final Value<String?> code;
  final Value<String> category;
  final Value<String?> subcategory;
  final Value<String?> unitType;
  final Value<String?> imageUrl;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<String?> brand;
  final Value<String?> material;
  final Value<String?> moistureResistance;
  final Value<String?> installationMethod;
  final Value<String?> defaultSupplierId;
  final Value<int> rowid;
  const LocalProductsCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.category = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.unitType = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.brand = const Value.absent(),
    this.material = const Value.absent(),
    this.moistureResistance = const Value.absent(),
    this.installationMethod = const Value.absent(),
    this.defaultSupplierId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProductsCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String name,
    this.code = const Value.absent(),
    required String category,
    this.subcategory = const Value.absent(),
    this.unitType = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.brand = const Value.absent(),
    this.material = const Value.absent(),
    this.moistureResistance = const Value.absent(),
    this.installationMethod = const Value.absent(),
    this.defaultSupplierId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       category = Value(category);
  static Insertable<LocalProduct> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? category,
    Expression<String>? subcategory,
    Expression<String>? unitType,
    Expression<String>? imageUrl,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<String>? brand,
    Expression<String>? material,
    Expression<String>? moistureResistance,
    Expression<String>? installationMethod,
    Expression<String>? defaultSupplierId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (category != null) 'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (unitType != null) 'unit_type': unitType,
      if (imageUrl != null) 'image_url': imageUrl,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (brand != null) 'brand': brand,
      if (material != null) 'material': material,
      if (moistureResistance != null) 'moisture_resistance': moistureResistance,
      if (installationMethod != null) 'installation_method': installationMethod,
      if (defaultSupplierId != null) 'default_supplier_id': defaultSupplierId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? name,
    Value<String?>? code,
    Value<String>? category,
    Value<String?>? subcategory,
    Value<String?>? unitType,
    Value<String?>? imageUrl,
    Value<String?>? notes,
    Value<bool>? isActive,
    Value<String?>? brand,
    Value<String?>? material,
    Value<String?>? moistureResistance,
    Value<String?>? installationMethod,
    Value<String?>? defaultSupplierId,
    Value<int>? rowid,
  }) {
    return LocalProductsCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      code: code ?? this.code,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      unitType: unitType ?? this.unitType,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      brand: brand ?? this.brand,
      material: material ?? this.material,
      moistureResistance: moistureResistance ?? this.moistureResistance,
      installationMethod: installationMethod ?? this.installationMethod,
      defaultSupplierId: defaultSupplierId ?? this.defaultSupplierId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (unitType.present) {
      map['unit_type'] = Variable<String>(unitType.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (material.present) {
      map['material'] = Variable<String>(material.value);
    }
    if (moistureResistance.present) {
      map['moisture_resistance'] = Variable<String>(moistureResistance.value);
    }
    if (installationMethod.present) {
      map['installation_method'] = Variable<String>(installationMethod.value);
    }
    if (defaultSupplierId.present) {
      map['default_supplier_id'] = Variable<String>(defaultSupplierId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProductsCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('unitType: $unitType, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('brand: $brand, ')
          ..write('material: $material, ')
          ..write('moistureResistance: $moistureResistance, ')
          ..write('installationMethod: $installationMethod, ')
          ..write('defaultSupplierId: $defaultSupplierId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalProductVariantsTable extends LocalProductVariants
    with TableInfo<$LocalProductVariantsTable, LocalProductVariant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProductVariantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variantNameMeta = const VerificationMeta(
    'variantName',
  );
  @override
  late final GeneratedColumn<String> variantName = GeneratedColumn<String>(
    'variant_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dimensionsMeta = const VerificationMeta(
    'dimensions',
  );
  @override
  late final GeneratedColumn<String> dimensions = GeneratedColumn<String>(
    'dimensions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pieceLengthMeta = const VerificationMeta(
    'pieceLength',
  );
  @override
  late final GeneratedColumn<double> pieceLength = GeneratedColumn<double>(
    'piece_length',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pieceWidthMeta = const VerificationMeta(
    'pieceWidth',
  );
  @override
  late final GeneratedColumn<double> pieceWidth = GeneratedColumn<double>(
    'piece_width',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thicknessMeta = const VerificationMeta(
    'thickness',
  );
  @override
  late final GeneratedColumn<double> thickness = GeneratedColumn<double>(
    'thickness',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _effectiveCoverageWidthMeta =
      const VerificationMeta('effectiveCoverageWidth');
  @override
  late final GeneratedColumn<double> effectiveCoverageWidth =
      GeneratedColumn<double>(
        'effective_coverage_width',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _defaultWastePercentMeta =
      const VerificationMeta('defaultWastePercent');
  @override
  late final GeneratedColumn<double> defaultWastePercent =
      GeneratedColumn<double>(
        'default_waste_percent',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minSellingPriceMeta = const VerificationMeta(
    'minSellingPrice',
  );
  @override
  late final GeneratedColumn<double> minSellingPrice = GeneratedColumn<double>(
    'min_selling_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costPriceOverrideMeta = const VerificationMeta(
    'costPriceOverride',
  );
  @override
  late final GeneratedColumn<double> costPriceOverride =
      GeneratedColumn<double>(
        'cost_price_override',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sellingPriceOverrideMeta =
      const VerificationMeta('sellingPriceOverride');
  @override
  late final GeneratedColumn<double> sellingPriceOverride =
      GeneratedColumn<double>(
        'selling_price_override',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _technicianPriceOverrideMeta =
      const VerificationMeta('technicianPriceOverride');
  @override
  late final GeneratedColumn<double> technicianPriceOverride =
      GeneratedColumn<double>(
        'technician_price_override',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    productId,
    variantName,
    color,
    dimensions,
    pieceLength,
    pieceWidth,
    thickness,
    effectiveCoverageWidth,
    defaultWastePercent,
    imageUrl,
    minSellingPrice,
    costPriceOverride,
    sellingPriceOverride,
    technicianPriceOverride,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_product_variants';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalProductVariant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('variant_name')) {
      context.handle(
        _variantNameMeta,
        variantName.isAcceptableOrUnknown(
          data['variant_name']!,
          _variantNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_variantNameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('dimensions')) {
      context.handle(
        _dimensionsMeta,
        dimensions.isAcceptableOrUnknown(data['dimensions']!, _dimensionsMeta),
      );
    }
    if (data.containsKey('piece_length')) {
      context.handle(
        _pieceLengthMeta,
        pieceLength.isAcceptableOrUnknown(
          data['piece_length']!,
          _pieceLengthMeta,
        ),
      );
    }
    if (data.containsKey('piece_width')) {
      context.handle(
        _pieceWidthMeta,
        pieceWidth.isAcceptableOrUnknown(data['piece_width']!, _pieceWidthMeta),
      );
    }
    if (data.containsKey('thickness')) {
      context.handle(
        _thicknessMeta,
        thickness.isAcceptableOrUnknown(data['thickness']!, _thicknessMeta),
      );
    }
    if (data.containsKey('effective_coverage_width')) {
      context.handle(
        _effectiveCoverageWidthMeta,
        effectiveCoverageWidth.isAcceptableOrUnknown(
          data['effective_coverage_width']!,
          _effectiveCoverageWidthMeta,
        ),
      );
    }
    if (data.containsKey('default_waste_percent')) {
      context.handle(
        _defaultWastePercentMeta,
        defaultWastePercent.isAcceptableOrUnknown(
          data['default_waste_percent']!,
          _defaultWastePercentMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('min_selling_price')) {
      context.handle(
        _minSellingPriceMeta,
        minSellingPrice.isAcceptableOrUnknown(
          data['min_selling_price']!,
          _minSellingPriceMeta,
        ),
      );
    }
    if (data.containsKey('cost_price_override')) {
      context.handle(
        _costPriceOverrideMeta,
        costPriceOverride.isAcceptableOrUnknown(
          data['cost_price_override']!,
          _costPriceOverrideMeta,
        ),
      );
    }
    if (data.containsKey('selling_price_override')) {
      context.handle(
        _sellingPriceOverrideMeta,
        sellingPriceOverride.isAcceptableOrUnknown(
          data['selling_price_override']!,
          _sellingPriceOverrideMeta,
        ),
      );
    }
    if (data.containsKey('technician_price_override')) {
      context.handle(
        _technicianPriceOverrideMeta,
        technicianPriceOverride.isAcceptableOrUnknown(
          data['technician_price_override']!,
          _technicianPriceOverrideMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalProductVariant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProductVariant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      variantName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      dimensions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dimensions'],
      ),
      pieceLength: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}piece_length'],
      ),
      pieceWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}piece_width'],
      ),
      thickness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}thickness'],
      ),
      effectiveCoverageWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}effective_coverage_width'],
      ),
      defaultWastePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_waste_percent'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      minSellingPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_selling_price'],
      ),
      costPriceOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_price_override'],
      ),
      sellingPriceOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}selling_price_override'],
      ),
      technicianPriceOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}technician_price_override'],
      ),
    );
  }

  @override
  $LocalProductVariantsTable createAlias(String alias) {
    return $LocalProductVariantsTable(attachedDatabase, alias);
  }
}

class LocalProductVariant extends DataClass
    implements Insertable<LocalProductVariant> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String productId;
  final String variantName;
  final String? color;
  final String? dimensions;
  final double? pieceLength;
  final double? pieceWidth;
  final double? thickness;
  final double? effectiveCoverageWidth;
  final double? defaultWastePercent;
  final String? imageUrl;
  final double? minSellingPrice;
  final double? costPriceOverride;
  final double? sellingPriceOverride;
  final double? technicianPriceOverride;
  const LocalProductVariant({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.productId,
    required this.variantName,
    this.color,
    this.dimensions,
    this.pieceLength,
    this.pieceWidth,
    this.thickness,
    this.effectiveCoverageWidth,
    this.defaultWastePercent,
    this.imageUrl,
    this.minSellingPrice,
    this.costPriceOverride,
    this.sellingPriceOverride,
    this.technicianPriceOverride,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['product_id'] = Variable<String>(productId);
    map['variant_name'] = Variable<String>(variantName);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || dimensions != null) {
      map['dimensions'] = Variable<String>(dimensions);
    }
    if (!nullToAbsent || pieceLength != null) {
      map['piece_length'] = Variable<double>(pieceLength);
    }
    if (!nullToAbsent || pieceWidth != null) {
      map['piece_width'] = Variable<double>(pieceWidth);
    }
    if (!nullToAbsent || thickness != null) {
      map['thickness'] = Variable<double>(thickness);
    }
    if (!nullToAbsent || effectiveCoverageWidth != null) {
      map['effective_coverage_width'] = Variable<double>(
        effectiveCoverageWidth,
      );
    }
    if (!nullToAbsent || defaultWastePercent != null) {
      map['default_waste_percent'] = Variable<double>(defaultWastePercent);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || minSellingPrice != null) {
      map['min_selling_price'] = Variable<double>(minSellingPrice);
    }
    if (!nullToAbsent || costPriceOverride != null) {
      map['cost_price_override'] = Variable<double>(costPriceOverride);
    }
    if (!nullToAbsent || sellingPriceOverride != null) {
      map['selling_price_override'] = Variable<double>(sellingPriceOverride);
    }
    if (!nullToAbsent || technicianPriceOverride != null) {
      map['technician_price_override'] = Variable<double>(
        technicianPriceOverride,
      );
    }
    return map;
  }

  LocalProductVariantsCompanion toCompanion(bool nullToAbsent) {
    return LocalProductVariantsCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      productId: Value(productId),
      variantName: Value(variantName),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      dimensions: dimensions == null && nullToAbsent
          ? const Value.absent()
          : Value(dimensions),
      pieceLength: pieceLength == null && nullToAbsent
          ? const Value.absent()
          : Value(pieceLength),
      pieceWidth: pieceWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(pieceWidth),
      thickness: thickness == null && nullToAbsent
          ? const Value.absent()
          : Value(thickness),
      effectiveCoverageWidth: effectiveCoverageWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(effectiveCoverageWidth),
      defaultWastePercent: defaultWastePercent == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultWastePercent),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      minSellingPrice: minSellingPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(minSellingPrice),
      costPriceOverride: costPriceOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(costPriceOverride),
      sellingPriceOverride: sellingPriceOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(sellingPriceOverride),
      technicianPriceOverride: technicianPriceOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(technicianPriceOverride),
    );
  }

  factory LocalProductVariant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProductVariant(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      productId: serializer.fromJson<String>(json['productId']),
      variantName: serializer.fromJson<String>(json['variantName']),
      color: serializer.fromJson<String?>(json['color']),
      dimensions: serializer.fromJson<String?>(json['dimensions']),
      pieceLength: serializer.fromJson<double?>(json['pieceLength']),
      pieceWidth: serializer.fromJson<double?>(json['pieceWidth']),
      thickness: serializer.fromJson<double?>(json['thickness']),
      effectiveCoverageWidth: serializer.fromJson<double?>(
        json['effectiveCoverageWidth'],
      ),
      defaultWastePercent: serializer.fromJson<double?>(
        json['defaultWastePercent'],
      ),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      minSellingPrice: serializer.fromJson<double?>(json['minSellingPrice']),
      costPriceOverride: serializer.fromJson<double?>(
        json['costPriceOverride'],
      ),
      sellingPriceOverride: serializer.fromJson<double?>(
        json['sellingPriceOverride'],
      ),
      technicianPriceOverride: serializer.fromJson<double?>(
        json['technicianPriceOverride'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'productId': serializer.toJson<String>(productId),
      'variantName': serializer.toJson<String>(variantName),
      'color': serializer.toJson<String?>(color),
      'dimensions': serializer.toJson<String?>(dimensions),
      'pieceLength': serializer.toJson<double?>(pieceLength),
      'pieceWidth': serializer.toJson<double?>(pieceWidth),
      'thickness': serializer.toJson<double?>(thickness),
      'effectiveCoverageWidth': serializer.toJson<double?>(
        effectiveCoverageWidth,
      ),
      'defaultWastePercent': serializer.toJson<double?>(defaultWastePercent),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'minSellingPrice': serializer.toJson<double?>(minSellingPrice),
      'costPriceOverride': serializer.toJson<double?>(costPriceOverride),
      'sellingPriceOverride': serializer.toJson<double?>(sellingPriceOverride),
      'technicianPriceOverride': serializer.toJson<double?>(
        technicianPriceOverride,
      ),
    };
  }

  LocalProductVariant copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? productId,
    String? variantName,
    Value<String?> color = const Value.absent(),
    Value<String?> dimensions = const Value.absent(),
    Value<double?> pieceLength = const Value.absent(),
    Value<double?> pieceWidth = const Value.absent(),
    Value<double?> thickness = const Value.absent(),
    Value<double?> effectiveCoverageWidth = const Value.absent(),
    Value<double?> defaultWastePercent = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<double?> minSellingPrice = const Value.absent(),
    Value<double?> costPriceOverride = const Value.absent(),
    Value<double?> sellingPriceOverride = const Value.absent(),
    Value<double?> technicianPriceOverride = const Value.absent(),
  }) => LocalProductVariant(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    productId: productId ?? this.productId,
    variantName: variantName ?? this.variantName,
    color: color.present ? color.value : this.color,
    dimensions: dimensions.present ? dimensions.value : this.dimensions,
    pieceLength: pieceLength.present ? pieceLength.value : this.pieceLength,
    pieceWidth: pieceWidth.present ? pieceWidth.value : this.pieceWidth,
    thickness: thickness.present ? thickness.value : this.thickness,
    effectiveCoverageWidth: effectiveCoverageWidth.present
        ? effectiveCoverageWidth.value
        : this.effectiveCoverageWidth,
    defaultWastePercent: defaultWastePercent.present
        ? defaultWastePercent.value
        : this.defaultWastePercent,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    minSellingPrice: minSellingPrice.present
        ? minSellingPrice.value
        : this.minSellingPrice,
    costPriceOverride: costPriceOverride.present
        ? costPriceOverride.value
        : this.costPriceOverride,
    sellingPriceOverride: sellingPriceOverride.present
        ? sellingPriceOverride.value
        : this.sellingPriceOverride,
    technicianPriceOverride: technicianPriceOverride.present
        ? technicianPriceOverride.value
        : this.technicianPriceOverride,
  );
  LocalProductVariant copyWithCompanion(LocalProductVariantsCompanion data) {
    return LocalProductVariant(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      productId: data.productId.present ? data.productId.value : this.productId,
      variantName: data.variantName.present
          ? data.variantName.value
          : this.variantName,
      color: data.color.present ? data.color.value : this.color,
      dimensions: data.dimensions.present
          ? data.dimensions.value
          : this.dimensions,
      pieceLength: data.pieceLength.present
          ? data.pieceLength.value
          : this.pieceLength,
      pieceWidth: data.pieceWidth.present
          ? data.pieceWidth.value
          : this.pieceWidth,
      thickness: data.thickness.present ? data.thickness.value : this.thickness,
      effectiveCoverageWidth: data.effectiveCoverageWidth.present
          ? data.effectiveCoverageWidth.value
          : this.effectiveCoverageWidth,
      defaultWastePercent: data.defaultWastePercent.present
          ? data.defaultWastePercent.value
          : this.defaultWastePercent,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      minSellingPrice: data.minSellingPrice.present
          ? data.minSellingPrice.value
          : this.minSellingPrice,
      costPriceOverride: data.costPriceOverride.present
          ? data.costPriceOverride.value
          : this.costPriceOverride,
      sellingPriceOverride: data.sellingPriceOverride.present
          ? data.sellingPriceOverride.value
          : this.sellingPriceOverride,
      technicianPriceOverride: data.technicianPriceOverride.present
          ? data.technicianPriceOverride.value
          : this.technicianPriceOverride,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProductVariant(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('productId: $productId, ')
          ..write('variantName: $variantName, ')
          ..write('color: $color, ')
          ..write('dimensions: $dimensions, ')
          ..write('pieceLength: $pieceLength, ')
          ..write('pieceWidth: $pieceWidth, ')
          ..write('thickness: $thickness, ')
          ..write('effectiveCoverageWidth: $effectiveCoverageWidth, ')
          ..write('defaultWastePercent: $defaultWastePercent, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('minSellingPrice: $minSellingPrice, ')
          ..write('costPriceOverride: $costPriceOverride, ')
          ..write('sellingPriceOverride: $sellingPriceOverride, ')
          ..write('technicianPriceOverride: $technicianPriceOverride')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    productId,
    variantName,
    color,
    dimensions,
    pieceLength,
    pieceWidth,
    thickness,
    effectiveCoverageWidth,
    defaultWastePercent,
    imageUrl,
    minSellingPrice,
    costPriceOverride,
    sellingPriceOverride,
    technicianPriceOverride,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProductVariant &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.productId == this.productId &&
          other.variantName == this.variantName &&
          other.color == this.color &&
          other.dimensions == this.dimensions &&
          other.pieceLength == this.pieceLength &&
          other.pieceWidth == this.pieceWidth &&
          other.thickness == this.thickness &&
          other.effectiveCoverageWidth == this.effectiveCoverageWidth &&
          other.defaultWastePercent == this.defaultWastePercent &&
          other.imageUrl == this.imageUrl &&
          other.minSellingPrice == this.minSellingPrice &&
          other.costPriceOverride == this.costPriceOverride &&
          other.sellingPriceOverride == this.sellingPriceOverride &&
          other.technicianPriceOverride == this.technicianPriceOverride);
}

class LocalProductVariantsCompanion
    extends UpdateCompanion<LocalProductVariant> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> productId;
  final Value<String> variantName;
  final Value<String?> color;
  final Value<String?> dimensions;
  final Value<double?> pieceLength;
  final Value<double?> pieceWidth;
  final Value<double?> thickness;
  final Value<double?> effectiveCoverageWidth;
  final Value<double?> defaultWastePercent;
  final Value<String?> imageUrl;
  final Value<double?> minSellingPrice;
  final Value<double?> costPriceOverride;
  final Value<double?> sellingPriceOverride;
  final Value<double?> technicianPriceOverride;
  final Value<int> rowid;
  const LocalProductVariantsCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.productId = const Value.absent(),
    this.variantName = const Value.absent(),
    this.color = const Value.absent(),
    this.dimensions = const Value.absent(),
    this.pieceLength = const Value.absent(),
    this.pieceWidth = const Value.absent(),
    this.thickness = const Value.absent(),
    this.effectiveCoverageWidth = const Value.absent(),
    this.defaultWastePercent = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.minSellingPrice = const Value.absent(),
    this.costPriceOverride = const Value.absent(),
    this.sellingPriceOverride = const Value.absent(),
    this.technicianPriceOverride = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProductVariantsCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String productId,
    required String variantName,
    this.color = const Value.absent(),
    this.dimensions = const Value.absent(),
    this.pieceLength = const Value.absent(),
    this.pieceWidth = const Value.absent(),
    this.thickness = const Value.absent(),
    this.effectiveCoverageWidth = const Value.absent(),
    this.defaultWastePercent = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.minSellingPrice = const Value.absent(),
    this.costPriceOverride = const Value.absent(),
    this.sellingPriceOverride = const Value.absent(),
    this.technicianPriceOverride = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : productId = Value(productId),
       variantName = Value(variantName);
  static Insertable<LocalProductVariant> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? productId,
    Expression<String>? variantName,
    Expression<String>? color,
    Expression<String>? dimensions,
    Expression<double>? pieceLength,
    Expression<double>? pieceWidth,
    Expression<double>? thickness,
    Expression<double>? effectiveCoverageWidth,
    Expression<double>? defaultWastePercent,
    Expression<String>? imageUrl,
    Expression<double>? minSellingPrice,
    Expression<double>? costPriceOverride,
    Expression<double>? sellingPriceOverride,
    Expression<double>? technicianPriceOverride,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (productId != null) 'product_id': productId,
      if (variantName != null) 'variant_name': variantName,
      if (color != null) 'color': color,
      if (dimensions != null) 'dimensions': dimensions,
      if (pieceLength != null) 'piece_length': pieceLength,
      if (pieceWidth != null) 'piece_width': pieceWidth,
      if (thickness != null) 'thickness': thickness,
      if (effectiveCoverageWidth != null)
        'effective_coverage_width': effectiveCoverageWidth,
      if (defaultWastePercent != null)
        'default_waste_percent': defaultWastePercent,
      if (imageUrl != null) 'image_url': imageUrl,
      if (minSellingPrice != null) 'min_selling_price': minSellingPrice,
      if (costPriceOverride != null) 'cost_price_override': costPriceOverride,
      if (sellingPriceOverride != null)
        'selling_price_override': sellingPriceOverride,
      if (technicianPriceOverride != null)
        'technician_price_override': technicianPriceOverride,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProductVariantsCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? productId,
    Value<String>? variantName,
    Value<String?>? color,
    Value<String?>? dimensions,
    Value<double?>? pieceLength,
    Value<double?>? pieceWidth,
    Value<double?>? thickness,
    Value<double?>? effectiveCoverageWidth,
    Value<double?>? defaultWastePercent,
    Value<String?>? imageUrl,
    Value<double?>? minSellingPrice,
    Value<double?>? costPriceOverride,
    Value<double?>? sellingPriceOverride,
    Value<double?>? technicianPriceOverride,
    Value<int>? rowid,
  }) {
    return LocalProductVariantsCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productId: productId ?? this.productId,
      variantName: variantName ?? this.variantName,
      color: color ?? this.color,
      dimensions: dimensions ?? this.dimensions,
      pieceLength: pieceLength ?? this.pieceLength,
      pieceWidth: pieceWidth ?? this.pieceWidth,
      thickness: thickness ?? this.thickness,
      effectiveCoverageWidth:
          effectiveCoverageWidth ?? this.effectiveCoverageWidth,
      defaultWastePercent: defaultWastePercent ?? this.defaultWastePercent,
      imageUrl: imageUrl ?? this.imageUrl,
      minSellingPrice: minSellingPrice ?? this.minSellingPrice,
      costPriceOverride: costPriceOverride ?? this.costPriceOverride,
      sellingPriceOverride: sellingPriceOverride ?? this.sellingPriceOverride,
      technicianPriceOverride:
          technicianPriceOverride ?? this.technicianPriceOverride,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (variantName.present) {
      map['variant_name'] = Variable<String>(variantName.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (dimensions.present) {
      map['dimensions'] = Variable<String>(dimensions.value);
    }
    if (pieceLength.present) {
      map['piece_length'] = Variable<double>(pieceLength.value);
    }
    if (pieceWidth.present) {
      map['piece_width'] = Variable<double>(pieceWidth.value);
    }
    if (thickness.present) {
      map['thickness'] = Variable<double>(thickness.value);
    }
    if (effectiveCoverageWidth.present) {
      map['effective_coverage_width'] = Variable<double>(
        effectiveCoverageWidth.value,
      );
    }
    if (defaultWastePercent.present) {
      map['default_waste_percent'] = Variable<double>(
        defaultWastePercent.value,
      );
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (minSellingPrice.present) {
      map['min_selling_price'] = Variable<double>(minSellingPrice.value);
    }
    if (costPriceOverride.present) {
      map['cost_price_override'] = Variable<double>(costPriceOverride.value);
    }
    if (sellingPriceOverride.present) {
      map['selling_price_override'] = Variable<double>(
        sellingPriceOverride.value,
      );
    }
    if (technicianPriceOverride.present) {
      map['technician_price_override'] = Variable<double>(
        technicianPriceOverride.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProductVariantsCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('productId: $productId, ')
          ..write('variantName: $variantName, ')
          ..write('color: $color, ')
          ..write('dimensions: $dimensions, ')
          ..write('pieceLength: $pieceLength, ')
          ..write('pieceWidth: $pieceWidth, ')
          ..write('thickness: $thickness, ')
          ..write('effectiveCoverageWidth: $effectiveCoverageWidth, ')
          ..write('defaultWastePercent: $defaultWastePercent, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('minSellingPrice: $minSellingPrice, ')
          ..write('costPriceOverride: $costPriceOverride, ')
          ..write('sellingPriceOverride: $sellingPriceOverride, ')
          ..write('technicianPriceOverride: $technicianPriceOverride, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSupplierPricingsTable extends LocalSupplierPricings
    with TableInfo<$LocalSupplierPricingsTable, LocalSupplierPricing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSupplierPricingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _productVariantIdMeta = const VerificationMeta(
    'productVariantId',
  );
  @override
  late final GeneratedColumn<String> productVariantId = GeneratedColumn<String>(
    'product_variant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplierCodeMeta = const VerificationMeta(
    'supplierCode',
  );
  @override
  late final GeneratedColumn<String> supplierCode = GeneratedColumn<String>(
    'supplier_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _listPriceMeta = const VerificationMeta(
    'listPrice',
  );
  @override
  late final GeneratedColumn<double> listPrice = GeneratedColumn<double>(
    'list_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _netPriceMeta = const VerificationMeta(
    'netPrice',
  );
  @override
  late final GeneratedColumn<double> netPrice = GeneratedColumn<double>(
    'net_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _discountValueMeta = const VerificationMeta(
    'discountValue',
  );
  @override
  late final GeneratedColumn<double> discountValue = GeneratedColumn<double>(
    'discount_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _isPreferredMeta = const VerificationMeta(
    'isPreferred',
  );
  @override
  late final GeneratedColumn<bool> isPreferred = GeneratedColumn<bool>(
    'is_preferred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_preferred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    productVariantId,
    supplierId,
    supplierCode,
    listPrice,
    netPrice,
    discountValue,
    isPreferred,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_supplier_pricings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSupplierPricing> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('product_variant_id')) {
      context.handle(
        _productVariantIdMeta,
        productVariantId.isAcceptableOrUnknown(
          data['product_variant_id']!,
          _productVariantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productVariantIdMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    }
    if (data.containsKey('supplier_code')) {
      context.handle(
        _supplierCodeMeta,
        supplierCode.isAcceptableOrUnknown(
          data['supplier_code']!,
          _supplierCodeMeta,
        ),
      );
    }
    if (data.containsKey('list_price')) {
      context.handle(
        _listPriceMeta,
        listPrice.isAcceptableOrUnknown(data['list_price']!, _listPriceMeta),
      );
    }
    if (data.containsKey('net_price')) {
      context.handle(
        _netPriceMeta,
        netPrice.isAcceptableOrUnknown(data['net_price']!, _netPriceMeta),
      );
    }
    if (data.containsKey('discount_value')) {
      context.handle(
        _discountValueMeta,
        discountValue.isAcceptableOrUnknown(
          data['discount_value']!,
          _discountValueMeta,
        ),
      );
    }
    if (data.containsKey('is_preferred')) {
      context.handle(
        _isPreferredMeta,
        isPreferred.isAcceptableOrUnknown(
          data['is_preferred']!,
          _isPreferredMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSupplierPricing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSupplierPricing(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      productVariantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_variant_id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      ),
      supplierCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_code'],
      ),
      listPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}list_price'],
      )!,
      netPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}net_price'],
      )!,
      discountValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_value'],
      )!,
      isPreferred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_preferred'],
      )!,
    );
  }

  @override
  $LocalSupplierPricingsTable createAlias(String alias) {
    return $LocalSupplierPricingsTable(attachedDatabase, alias);
  }
}

class LocalSupplierPricing extends DataClass
    implements Insertable<LocalSupplierPricing> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String productVariantId;
  final String? supplierId;
  final String? supplierCode;
  final double listPrice;
  final double netPrice;
  final double discountValue;
  final bool isPreferred;
  const LocalSupplierPricing({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.productVariantId,
    this.supplierId,
    this.supplierCode,
    required this.listPrice,
    required this.netPrice,
    required this.discountValue,
    required this.isPreferred,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['product_variant_id'] = Variable<String>(productVariantId);
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    if (!nullToAbsent || supplierCode != null) {
      map['supplier_code'] = Variable<String>(supplierCode);
    }
    map['list_price'] = Variable<double>(listPrice);
    map['net_price'] = Variable<double>(netPrice);
    map['discount_value'] = Variable<double>(discountValue);
    map['is_preferred'] = Variable<bool>(isPreferred);
    return map;
  }

  LocalSupplierPricingsCompanion toCompanion(bool nullToAbsent) {
    return LocalSupplierPricingsCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      productVariantId: Value(productVariantId),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      supplierCode: supplierCode == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierCode),
      listPrice: Value(listPrice),
      netPrice: Value(netPrice),
      discountValue: Value(discountValue),
      isPreferred: Value(isPreferred),
    );
  }

  factory LocalSupplierPricing.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSupplierPricing(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      productVariantId: serializer.fromJson<String>(json['productVariantId']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      supplierCode: serializer.fromJson<String?>(json['supplierCode']),
      listPrice: serializer.fromJson<double>(json['listPrice']),
      netPrice: serializer.fromJson<double>(json['netPrice']),
      discountValue: serializer.fromJson<double>(json['discountValue']),
      isPreferred: serializer.fromJson<bool>(json['isPreferred']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'productVariantId': serializer.toJson<String>(productVariantId),
      'supplierId': serializer.toJson<String?>(supplierId),
      'supplierCode': serializer.toJson<String?>(supplierCode),
      'listPrice': serializer.toJson<double>(listPrice),
      'netPrice': serializer.toJson<double>(netPrice),
      'discountValue': serializer.toJson<double>(discountValue),
      'isPreferred': serializer.toJson<bool>(isPreferred),
    };
  }

  LocalSupplierPricing copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? productVariantId,
    Value<String?> supplierId = const Value.absent(),
    Value<String?> supplierCode = const Value.absent(),
    double? listPrice,
    double? netPrice,
    double? discountValue,
    bool? isPreferred,
  }) => LocalSupplierPricing(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    productVariantId: productVariantId ?? this.productVariantId,
    supplierId: supplierId.present ? supplierId.value : this.supplierId,
    supplierCode: supplierCode.present ? supplierCode.value : this.supplierCode,
    listPrice: listPrice ?? this.listPrice,
    netPrice: netPrice ?? this.netPrice,
    discountValue: discountValue ?? this.discountValue,
    isPreferred: isPreferred ?? this.isPreferred,
  );
  LocalSupplierPricing copyWithCompanion(LocalSupplierPricingsCompanion data) {
    return LocalSupplierPricing(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      productVariantId: data.productVariantId.present
          ? data.productVariantId.value
          : this.productVariantId,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      supplierCode: data.supplierCode.present
          ? data.supplierCode.value
          : this.supplierCode,
      listPrice: data.listPrice.present ? data.listPrice.value : this.listPrice,
      netPrice: data.netPrice.present ? data.netPrice.value : this.netPrice,
      discountValue: data.discountValue.present
          ? data.discountValue.value
          : this.discountValue,
      isPreferred: data.isPreferred.present
          ? data.isPreferred.value
          : this.isPreferred,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSupplierPricing(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('productVariantId: $productVariantId, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplierCode: $supplierCode, ')
          ..write('listPrice: $listPrice, ')
          ..write('netPrice: $netPrice, ')
          ..write('discountValue: $discountValue, ')
          ..write('isPreferred: $isPreferred')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    productVariantId,
    supplierId,
    supplierCode,
    listPrice,
    netPrice,
    discountValue,
    isPreferred,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSupplierPricing &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.productVariantId == this.productVariantId &&
          other.supplierId == this.supplierId &&
          other.supplierCode == this.supplierCode &&
          other.listPrice == this.listPrice &&
          other.netPrice == this.netPrice &&
          other.discountValue == this.discountValue &&
          other.isPreferred == this.isPreferred);
}

class LocalSupplierPricingsCompanion
    extends UpdateCompanion<LocalSupplierPricing> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> productVariantId;
  final Value<String?> supplierId;
  final Value<String?> supplierCode;
  final Value<double> listPrice;
  final Value<double> netPrice;
  final Value<double> discountValue;
  final Value<bool> isPreferred;
  final Value<int> rowid;
  const LocalSupplierPricingsCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.productVariantId = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.supplierCode = const Value.absent(),
    this.listPrice = const Value.absent(),
    this.netPrice = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.isPreferred = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSupplierPricingsCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String productVariantId,
    this.supplierId = const Value.absent(),
    this.supplierCode = const Value.absent(),
    this.listPrice = const Value.absent(),
    this.netPrice = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.isPreferred = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : productVariantId = Value(productVariantId);
  static Insertable<LocalSupplierPricing> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? productVariantId,
    Expression<String>? supplierId,
    Expression<String>? supplierCode,
    Expression<double>? listPrice,
    Expression<double>? netPrice,
    Expression<double>? discountValue,
    Expression<bool>? isPreferred,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (productVariantId != null) 'product_variant_id': productVariantId,
      if (supplierId != null) 'supplier_id': supplierId,
      if (supplierCode != null) 'supplier_code': supplierCode,
      if (listPrice != null) 'list_price': listPrice,
      if (netPrice != null) 'net_price': netPrice,
      if (discountValue != null) 'discount_value': discountValue,
      if (isPreferred != null) 'is_preferred': isPreferred,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSupplierPricingsCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? productVariantId,
    Value<String?>? supplierId,
    Value<String?>? supplierCode,
    Value<double>? listPrice,
    Value<double>? netPrice,
    Value<double>? discountValue,
    Value<bool>? isPreferred,
    Value<int>? rowid,
  }) {
    return LocalSupplierPricingsCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productVariantId: productVariantId ?? this.productVariantId,
      supplierId: supplierId ?? this.supplierId,
      supplierCode: supplierCode ?? this.supplierCode,
      listPrice: listPrice ?? this.listPrice,
      netPrice: netPrice ?? this.netPrice,
      discountValue: discountValue ?? this.discountValue,
      isPreferred: isPreferred ?? this.isPreferred,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (productVariantId.present) {
      map['product_variant_id'] = Variable<String>(productVariantId.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (supplierCode.present) {
      map['supplier_code'] = Variable<String>(supplierCode.value);
    }
    if (listPrice.present) {
      map['list_price'] = Variable<double>(listPrice.value);
    }
    if (netPrice.present) {
      map['net_price'] = Variable<double>(netPrice.value);
    }
    if (discountValue.present) {
      map['discount_value'] = Variable<double>(discountValue.value);
    }
    if (isPreferred.present) {
      map['is_preferred'] = Variable<bool>(isPreferred.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSupplierPricingsCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('productVariantId: $productVariantId, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplierCode: $supplierCode, ')
          ..write('listPrice: $listPrice, ')
          ..write('netPrice: $netPrice, ')
          ..write('discountValue: $discountValue, ')
          ..write('isPreferred: $isPreferred, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalInventoryItemsTable extends LocalInventoryItems
    with TableInfo<$LocalInventoryItemsTable, LocalInventoryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalInventoryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _productVariantIdMeta = const VerificationMeta(
    'productVariantId',
  );
  @override
  late final GeneratedColumn<String> productVariantId = GeneratedColumn<String>(
    'product_variant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _availableQtyMeta = const VerificationMeta(
    'availableQty',
  );
  @override
  late final GeneratedColumn<double> availableQty = GeneratedColumn<double>(
    'available_qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _reservedQtyMeta = const VerificationMeta(
    'reservedQty',
  );
  @override
  late final GeneratedColumn<double> reservedQty = GeneratedColumn<double>(
    'reserved_qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _damagedQtyMeta = const VerificationMeta(
    'damagedQty',
  );
  @override
  late final GeneratedColumn<double> damagedQty = GeneratedColumn<double>(
    'damaged_qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _reorderPointMeta = const VerificationMeta(
    'reorderPoint',
  );
  @override
  late final GeneratedColumn<double> reorderPoint = GeneratedColumn<double>(
    'reorder_point',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    productVariantId,
    availableQty,
    reservedQty,
    damagedQty,
    reorderPoint,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_inventory_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalInventoryItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('product_variant_id')) {
      context.handle(
        _productVariantIdMeta,
        productVariantId.isAcceptableOrUnknown(
          data['product_variant_id']!,
          _productVariantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productVariantIdMeta);
    }
    if (data.containsKey('available_qty')) {
      context.handle(
        _availableQtyMeta,
        availableQty.isAcceptableOrUnknown(
          data['available_qty']!,
          _availableQtyMeta,
        ),
      );
    }
    if (data.containsKey('reserved_qty')) {
      context.handle(
        _reservedQtyMeta,
        reservedQty.isAcceptableOrUnknown(
          data['reserved_qty']!,
          _reservedQtyMeta,
        ),
      );
    }
    if (data.containsKey('damaged_qty')) {
      context.handle(
        _damagedQtyMeta,
        damagedQty.isAcceptableOrUnknown(data['damaged_qty']!, _damagedQtyMeta),
      );
    }
    if (data.containsKey('reorder_point')) {
      context.handle(
        _reorderPointMeta,
        reorderPoint.isAcceptableOrUnknown(
          data['reorder_point']!,
          _reorderPointMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalInventoryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalInventoryItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      productVariantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_variant_id'],
      )!,
      availableQty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}available_qty'],
      )!,
      reservedQty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reserved_qty'],
      )!,
      damagedQty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}damaged_qty'],
      )!,
      reorderPoint: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reorder_point'],
      )!,
    );
  }

  @override
  $LocalInventoryItemsTable createAlias(String alias) {
    return $LocalInventoryItemsTable(attachedDatabase, alias);
  }
}

class LocalInventoryItem extends DataClass
    implements Insertable<LocalInventoryItem> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String productVariantId;
  final double availableQty;
  final double reservedQty;
  final double damagedQty;
  final double reorderPoint;
  const LocalInventoryItem({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.productVariantId,
    required this.availableQty,
    required this.reservedQty,
    required this.damagedQty,
    required this.reorderPoint,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['product_variant_id'] = Variable<String>(productVariantId);
    map['available_qty'] = Variable<double>(availableQty);
    map['reserved_qty'] = Variable<double>(reservedQty);
    map['damaged_qty'] = Variable<double>(damagedQty);
    map['reorder_point'] = Variable<double>(reorderPoint);
    return map;
  }

  LocalInventoryItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalInventoryItemsCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      productVariantId: Value(productVariantId),
      availableQty: Value(availableQty),
      reservedQty: Value(reservedQty),
      damagedQty: Value(damagedQty),
      reorderPoint: Value(reorderPoint),
    );
  }

  factory LocalInventoryItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalInventoryItem(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      productVariantId: serializer.fromJson<String>(json['productVariantId']),
      availableQty: serializer.fromJson<double>(json['availableQty']),
      reservedQty: serializer.fromJson<double>(json['reservedQty']),
      damagedQty: serializer.fromJson<double>(json['damagedQty']),
      reorderPoint: serializer.fromJson<double>(json['reorderPoint']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'productVariantId': serializer.toJson<String>(productVariantId),
      'availableQty': serializer.toJson<double>(availableQty),
      'reservedQty': serializer.toJson<double>(reservedQty),
      'damagedQty': serializer.toJson<double>(damagedQty),
      'reorderPoint': serializer.toJson<double>(reorderPoint),
    };
  }

  LocalInventoryItem copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? productVariantId,
    double? availableQty,
    double? reservedQty,
    double? damagedQty,
    double? reorderPoint,
  }) => LocalInventoryItem(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    productVariantId: productVariantId ?? this.productVariantId,
    availableQty: availableQty ?? this.availableQty,
    reservedQty: reservedQty ?? this.reservedQty,
    damagedQty: damagedQty ?? this.damagedQty,
    reorderPoint: reorderPoint ?? this.reorderPoint,
  );
  LocalInventoryItem copyWithCompanion(LocalInventoryItemsCompanion data) {
    return LocalInventoryItem(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      productVariantId: data.productVariantId.present
          ? data.productVariantId.value
          : this.productVariantId,
      availableQty: data.availableQty.present
          ? data.availableQty.value
          : this.availableQty,
      reservedQty: data.reservedQty.present
          ? data.reservedQty.value
          : this.reservedQty,
      damagedQty: data.damagedQty.present
          ? data.damagedQty.value
          : this.damagedQty,
      reorderPoint: data.reorderPoint.present
          ? data.reorderPoint.value
          : this.reorderPoint,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalInventoryItem(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('productVariantId: $productVariantId, ')
          ..write('availableQty: $availableQty, ')
          ..write('reservedQty: $reservedQty, ')
          ..write('damagedQty: $damagedQty, ')
          ..write('reorderPoint: $reorderPoint')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    productVariantId,
    availableQty,
    reservedQty,
    damagedQty,
    reorderPoint,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalInventoryItem &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.productVariantId == this.productVariantId &&
          other.availableQty == this.availableQty &&
          other.reservedQty == this.reservedQty &&
          other.damagedQty == this.damagedQty &&
          other.reorderPoint == this.reorderPoint);
}

class LocalInventoryItemsCompanion extends UpdateCompanion<LocalInventoryItem> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> productVariantId;
  final Value<double> availableQty;
  final Value<double> reservedQty;
  final Value<double> damagedQty;
  final Value<double> reorderPoint;
  final Value<int> rowid;
  const LocalInventoryItemsCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.productVariantId = const Value.absent(),
    this.availableQty = const Value.absent(),
    this.reservedQty = const Value.absent(),
    this.damagedQty = const Value.absent(),
    this.reorderPoint = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalInventoryItemsCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String productVariantId,
    this.availableQty = const Value.absent(),
    this.reservedQty = const Value.absent(),
    this.damagedQty = const Value.absent(),
    this.reorderPoint = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : productVariantId = Value(productVariantId);
  static Insertable<LocalInventoryItem> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? productVariantId,
    Expression<double>? availableQty,
    Expression<double>? reservedQty,
    Expression<double>? damagedQty,
    Expression<double>? reorderPoint,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (productVariantId != null) 'product_variant_id': productVariantId,
      if (availableQty != null) 'available_qty': availableQty,
      if (reservedQty != null) 'reserved_qty': reservedQty,
      if (damagedQty != null) 'damaged_qty': damagedQty,
      if (reorderPoint != null) 'reorder_point': reorderPoint,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalInventoryItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? productVariantId,
    Value<double>? availableQty,
    Value<double>? reservedQty,
    Value<double>? damagedQty,
    Value<double>? reorderPoint,
    Value<int>? rowid,
  }) {
    return LocalInventoryItemsCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productVariantId: productVariantId ?? this.productVariantId,
      availableQty: availableQty ?? this.availableQty,
      reservedQty: reservedQty ?? this.reservedQty,
      damagedQty: damagedQty ?? this.damagedQty,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (productVariantId.present) {
      map['product_variant_id'] = Variable<String>(productVariantId.value);
    }
    if (availableQty.present) {
      map['available_qty'] = Variable<double>(availableQty.value);
    }
    if (reservedQty.present) {
      map['reserved_qty'] = Variable<double>(reservedQty.value);
    }
    if (damagedQty.present) {
      map['damaged_qty'] = Variable<double>(damagedQty.value);
    }
    if (reorderPoint.present) {
      map['reorder_point'] = Variable<double>(reorderPoint.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalInventoryItemsCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('productVariantId: $productVariantId, ')
          ..write('availableQty: $availableQty, ')
          ..write('reservedQty: $reservedQty, ')
          ..write('damagedQty: $damagedQty, ')
          ..write('reorderPoint: $reorderPoint, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalInventoryMovementsTable extends LocalInventoryMovements
    with TableInfo<$LocalInventoryMovementsTable, LocalInventoryMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalInventoryMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _inventoryItemIdMeta = const VerificationMeta(
    'inventoryItemId',
  );
  @override
  late final GeneratedColumn<String> inventoryItemId = GeneratedColumn<String>(
    'inventory_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movementTypeMeta = const VerificationMeta(
    'movementType',
  );
  @override
  late final GeneratedColumn<String> movementType = GeneratedColumn<String>(
    'movement_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _referenceIdMeta = const VerificationMeta(
    'referenceId',
  );
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
    'reference_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    inventoryItemId,
    movementType,
    quantity,
    referenceId,
    notes,
    createdBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_inventory_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalInventoryMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('inventory_item_id')) {
      context.handle(
        _inventoryItemIdMeta,
        inventoryItemId.isAcceptableOrUnknown(
          data['inventory_item_id']!,
          _inventoryItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inventoryItemIdMeta);
    }
    if (data.containsKey('movement_type')) {
      context.handle(
        _movementTypeMeta,
        movementType.isAcceptableOrUnknown(
          data['movement_type']!,
          _movementTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_movementTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('reference_id')) {
      context.handle(
        _referenceIdMeta,
        referenceId.isAcceptableOrUnknown(
          data['reference_id']!,
          _referenceIdMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalInventoryMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalInventoryMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      inventoryItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inventory_item_id'],
      )!,
      movementType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movement_type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      referenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
    );
  }

  @override
  $LocalInventoryMovementsTable createAlias(String alias) {
    return $LocalInventoryMovementsTable(attachedDatabase, alias);
  }
}

class LocalInventoryMovement extends DataClass
    implements Insertable<LocalInventoryMovement> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String inventoryItemId;
  final String movementType;
  final double quantity;
  final String? referenceId;
  final String? notes;
  final String? createdBy;
  const LocalInventoryMovement({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.inventoryItemId,
    required this.movementType,
    required this.quantity,
    this.referenceId,
    this.notes,
    this.createdBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['inventory_item_id'] = Variable<String>(inventoryItemId);
    map['movement_type'] = Variable<String>(movementType);
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    return map;
  }

  LocalInventoryMovementsCompanion toCompanion(bool nullToAbsent) {
    return LocalInventoryMovementsCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      inventoryItemId: Value(inventoryItemId),
      movementType: Value(movementType),
      quantity: Value(quantity),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
    );
  }

  factory LocalInventoryMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalInventoryMovement(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      inventoryItemId: serializer.fromJson<String>(json['inventoryItemId']),
      movementType: serializer.fromJson<String>(json['movementType']),
      quantity: serializer.fromJson<double>(json['quantity']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'inventoryItemId': serializer.toJson<String>(inventoryItemId),
      'movementType': serializer.toJson<String>(movementType),
      'quantity': serializer.toJson<double>(quantity),
      'referenceId': serializer.toJson<String?>(referenceId),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String?>(createdBy),
    };
  }

  LocalInventoryMovement copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? inventoryItemId,
    String? movementType,
    double? quantity,
    Value<String?> referenceId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
  }) => LocalInventoryMovement(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    inventoryItemId: inventoryItemId ?? this.inventoryItemId,
    movementType: movementType ?? this.movementType,
    quantity: quantity ?? this.quantity,
    referenceId: referenceId.present ? referenceId.value : this.referenceId,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
  );
  LocalInventoryMovement copyWithCompanion(
    LocalInventoryMovementsCompanion data,
  ) {
    return LocalInventoryMovement(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      inventoryItemId: data.inventoryItemId.present
          ? data.inventoryItemId.value
          : this.inventoryItemId,
      movementType: data.movementType.present
          ? data.movementType.value
          : this.movementType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      referenceId: data.referenceId.present
          ? data.referenceId.value
          : this.referenceId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalInventoryMovement(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('inventoryItemId: $inventoryItemId, ')
          ..write('movementType: $movementType, ')
          ..write('quantity: $quantity, ')
          ..write('referenceId: $referenceId, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    inventoryItemId,
    movementType,
    quantity,
    referenceId,
    notes,
    createdBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalInventoryMovement &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.inventoryItemId == this.inventoryItemId &&
          other.movementType == this.movementType &&
          other.quantity == this.quantity &&
          other.referenceId == this.referenceId &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy);
}

class LocalInventoryMovementsCompanion
    extends UpdateCompanion<LocalInventoryMovement> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> inventoryItemId;
  final Value<String> movementType;
  final Value<double> quantity;
  final Value<String?> referenceId;
  final Value<String?> notes;
  final Value<String?> createdBy;
  final Value<int> rowid;
  const LocalInventoryMovementsCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.inventoryItemId = const Value.absent(),
    this.movementType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalInventoryMovementsCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String inventoryItemId,
    required String movementType,
    this.quantity = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : inventoryItemId = Value(inventoryItemId),
       movementType = Value(movementType);
  static Insertable<LocalInventoryMovement> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? inventoryItemId,
    Expression<String>? movementType,
    Expression<double>? quantity,
    Expression<String>? referenceId,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (inventoryItemId != null) 'inventory_item_id': inventoryItemId,
      if (movementType != null) 'movement_type': movementType,
      if (quantity != null) 'quantity': quantity,
      if (referenceId != null) 'reference_id': referenceId,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalInventoryMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? inventoryItemId,
    Value<String>? movementType,
    Value<double>? quantity,
    Value<String?>? referenceId,
    Value<String?>? notes,
    Value<String?>? createdBy,
    Value<int>? rowid,
  }) {
    return LocalInventoryMovementsCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      movementType: movementType ?? this.movementType,
      quantity: quantity ?? this.quantity,
      referenceId: referenceId ?? this.referenceId,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (inventoryItemId.present) {
      map['inventory_item_id'] = Variable<String>(inventoryItemId.value);
    }
    if (movementType.present) {
      map['movement_type'] = Variable<String>(movementType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalInventoryMovementsCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('inventoryItemId: $inventoryItemId, ')
          ..write('movementType: $movementType, ')
          ..write('quantity: $quantity, ')
          ..write('referenceId: $referenceId, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalQuotesTable extends LocalQuotes
    with TableInfo<$LocalQuotesTable, LocalQuote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalQuotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _quoteNumberMeta = const VerificationMeta(
    'quoteNumber',
  );
  @override
  late final GeneratedColumn<String> quoteNumber = GeneratedColumn<String>(
    'quote_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _taxAmountMeta = const VerificationMeta(
    'taxAmount',
  );
  @override
  late final GeneratedColumn<double> taxAmount = GeneratedColumn<double>(
    'tax_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _discountAmountMeta = const VerificationMeta(
    'discountAmount',
  );
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
    'discount_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _validUntilMeta = const VerificationMeta(
    'validUntil',
  );
  @override
  late final GeneratedColumn<DateTime> validUntil = GeneratedColumn<DateTime>(
    'valid_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    quoteNumber,
    customerId,
    status,
    totalAmount,
    taxAmount,
    discountAmount,
    notes,
    validUntil,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_quotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalQuote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('quote_number')) {
      context.handle(
        _quoteNumberMeta,
        quoteNumber.isAcceptableOrUnknown(
          data['quote_number']!,
          _quoteNumberMeta,
        ),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    }
    if (data.containsKey('tax_amount')) {
      context.handle(
        _taxAmountMeta,
        taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta),
      );
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
        _discountAmountMeta,
        discountAmount.isAcceptableOrUnknown(
          data['discount_amount']!,
          _discountAmountMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('valid_until')) {
      context.handle(
        _validUntilMeta,
        validUntil.isAcceptableOrUnknown(data['valid_until']!, _validUntilMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalQuote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalQuote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      quoteNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote_number'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      taxAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_amount'],
      )!,
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_amount'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      validUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}valid_until'],
      ),
    );
  }

  @override
  $LocalQuotesTable createAlias(String alias) {
    return $LocalQuotesTable(attachedDatabase, alias);
  }
}

class LocalQuote extends DataClass implements Insertable<LocalQuote> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? quoteNumber;
  final String? customerId;
  final String status;
  final double totalAmount;
  final double taxAmount;
  final double discountAmount;
  final String? notes;
  final DateTime? validUntil;
  const LocalQuote({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.quoteNumber,
    this.customerId,
    required this.status,
    required this.totalAmount,
    required this.taxAmount,
    required this.discountAmount,
    this.notes,
    this.validUntil,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || quoteNumber != null) {
      map['quote_number'] = Variable<String>(quoteNumber);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['status'] = Variable<String>(status);
    map['total_amount'] = Variable<double>(totalAmount);
    map['tax_amount'] = Variable<double>(taxAmount);
    map['discount_amount'] = Variable<double>(discountAmount);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || validUntil != null) {
      map['valid_until'] = Variable<DateTime>(validUntil);
    }
    return map;
  }

  LocalQuotesCompanion toCompanion(bool nullToAbsent) {
    return LocalQuotesCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      quoteNumber: quoteNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(quoteNumber),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      status: Value(status),
      totalAmount: Value(totalAmount),
      taxAmount: Value(taxAmount),
      discountAmount: Value(discountAmount),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      validUntil: validUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(validUntil),
    );
  }

  factory LocalQuote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalQuote(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      quoteNumber: serializer.fromJson<String?>(json['quoteNumber']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      status: serializer.fromJson<String>(json['status']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      taxAmount: serializer.fromJson<double>(json['taxAmount']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      notes: serializer.fromJson<String?>(json['notes']),
      validUntil: serializer.fromJson<DateTime?>(json['validUntil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'quoteNumber': serializer.toJson<String?>(quoteNumber),
      'customerId': serializer.toJson<String?>(customerId),
      'status': serializer.toJson<String>(status),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'taxAmount': serializer.toJson<double>(taxAmount),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'notes': serializer.toJson<String?>(notes),
      'validUntil': serializer.toJson<DateTime?>(validUntil),
    };
  }

  LocalQuote copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> quoteNumber = const Value.absent(),
    Value<String?> customerId = const Value.absent(),
    String? status,
    double? totalAmount,
    double? taxAmount,
    double? discountAmount,
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> validUntil = const Value.absent(),
  }) => LocalQuote(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    quoteNumber: quoteNumber.present ? quoteNumber.value : this.quoteNumber,
    customerId: customerId.present ? customerId.value : this.customerId,
    status: status ?? this.status,
    totalAmount: totalAmount ?? this.totalAmount,
    taxAmount: taxAmount ?? this.taxAmount,
    discountAmount: discountAmount ?? this.discountAmount,
    notes: notes.present ? notes.value : this.notes,
    validUntil: validUntil.present ? validUntil.value : this.validUntil,
  );
  LocalQuote copyWithCompanion(LocalQuotesCompanion data) {
    return LocalQuote(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      quoteNumber: data.quoteNumber.present
          ? data.quoteNumber.value
          : this.quoteNumber,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      status: data.status.present ? data.status.value : this.status,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      notes: data.notes.present ? data.notes.value : this.notes,
      validUntil: data.validUntil.present
          ? data.validUntil.value
          : this.validUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuote(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('quoteNumber: $quoteNumber, ')
          ..write('customerId: $customerId, ')
          ..write('status: $status, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('notes: $notes, ')
          ..write('validUntil: $validUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    quoteNumber,
    customerId,
    status,
    totalAmount,
    taxAmount,
    discountAmount,
    notes,
    validUntil,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalQuote &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.quoteNumber == this.quoteNumber &&
          other.customerId == this.customerId &&
          other.status == this.status &&
          other.totalAmount == this.totalAmount &&
          other.taxAmount == this.taxAmount &&
          other.discountAmount == this.discountAmount &&
          other.notes == this.notes &&
          other.validUntil == this.validUntil);
}

class LocalQuotesCompanion extends UpdateCompanion<LocalQuote> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> quoteNumber;
  final Value<String?> customerId;
  final Value<String> status;
  final Value<double> totalAmount;
  final Value<double> taxAmount;
  final Value<double> discountAmount;
  final Value<String?> notes;
  final Value<DateTime?> validUntil;
  final Value<int> rowid;
  const LocalQuotesCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.quoteNumber = const Value.absent(),
    this.customerId = const Value.absent(),
    this.status = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.notes = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalQuotesCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.quoteNumber = const Value.absent(),
    this.customerId = const Value.absent(),
    this.status = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.notes = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<LocalQuote> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? quoteNumber,
    Expression<String>? customerId,
    Expression<String>? status,
    Expression<double>? totalAmount,
    Expression<double>? taxAmount,
    Expression<double>? discountAmount,
    Expression<String>? notes,
    Expression<DateTime>? validUntil,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (quoteNumber != null) 'quote_number': quoteNumber,
      if (customerId != null) 'customer_id': customerId,
      if (status != null) 'status': status,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (notes != null) 'notes': notes,
      if (validUntil != null) 'valid_until': validUntil,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalQuotesCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? quoteNumber,
    Value<String?>? customerId,
    Value<String>? status,
    Value<double>? totalAmount,
    Value<double>? taxAmount,
    Value<double>? discountAmount,
    Value<String?>? notes,
    Value<DateTime?>? validUntil,
    Value<int>? rowid,
  }) {
    return LocalQuotesCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      quoteNumber: quoteNumber ?? this.quoteNumber,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      notes: notes ?? this.notes,
      validUntil: validUntil ?? this.validUntil,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (quoteNumber.present) {
      map['quote_number'] = Variable<String>(quoteNumber.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<double>(taxAmount.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (validUntil.present) {
      map['valid_until'] = Variable<DateTime>(validUntil.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuotesCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('quoteNumber: $quoteNumber, ')
          ..write('customerId: $customerId, ')
          ..write('status: $status, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('notes: $notes, ')
          ..write('validUntil: $validUntil, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalQuoteItemsTable extends LocalQuoteItems
    with TableInfo<$LocalQuoteItemsTable, LocalQuoteItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalQuoteItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _quoteIdMeta = const VerificationMeta(
    'quoteId',
  );
  @override
  late final GeneratedColumn<String> quoteId = GeneratedColumn<String>(
    'quote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productVariantIdMeta = const VerificationMeta(
    'productVariantId',
  );
  @override
  late final GeneratedColumn<String> productVariantId = GeneratedColumn<String>(
    'product_variant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalPriceMeta = const VerificationMeta(
    'totalPrice',
  );
  @override
  late final GeneratedColumn<double> totalPrice = GeneratedColumn<double>(
    'total_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    quoteId,
    productVariantId,
    quantity,
    unitPrice,
    totalPrice,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_quote_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalQuoteItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('quote_id')) {
      context.handle(
        _quoteIdMeta,
        quoteId.isAcceptableOrUnknown(data['quote_id']!, _quoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_quoteIdMeta);
    }
    if (data.containsKey('product_variant_id')) {
      context.handle(
        _productVariantIdMeta,
        productVariantId.isAcceptableOrUnknown(
          data['product_variant_id']!,
          _productVariantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productVariantIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    }
    if (data.containsKey('total_price')) {
      context.handle(
        _totalPriceMeta,
        totalPrice.isAcceptableOrUnknown(data['total_price']!, _totalPriceMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalQuoteItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalQuoteItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      quoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote_id'],
      )!,
      productVariantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_variant_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      totalPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_price'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $LocalQuoteItemsTable createAlias(String alias) {
    return $LocalQuoteItemsTable(attachedDatabase, alias);
  }
}

class LocalQuoteItem extends DataClass implements Insertable<LocalQuoteItem> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String quoteId;
  final String productVariantId;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;
  const LocalQuoteItem({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.quoteId,
    required this.productVariantId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['quote_id'] = Variable<String>(quoteId);
    map['product_variant_id'] = Variable<String>(productVariantId);
    map['quantity'] = Variable<double>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['total_price'] = Variable<double>(totalPrice);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  LocalQuoteItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalQuoteItemsCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      quoteId: Value(quoteId),
      productVariantId: Value(productVariantId),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      totalPrice: Value(totalPrice),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory LocalQuoteItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalQuoteItem(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      quoteId: serializer.fromJson<String>(json['quoteId']),
      productVariantId: serializer.fromJson<String>(json['productVariantId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      totalPrice: serializer.fromJson<double>(json['totalPrice']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'quoteId': serializer.toJson<String>(quoteId),
      'productVariantId': serializer.toJson<String>(productVariantId),
      'quantity': serializer.toJson<double>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'totalPrice': serializer.toJson<double>(totalPrice),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LocalQuoteItem copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? quoteId,
    String? productVariantId,
    double? quantity,
    double? unitPrice,
    double? totalPrice,
    Value<String?> notes = const Value.absent(),
  }) => LocalQuoteItem(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    quoteId: quoteId ?? this.quoteId,
    productVariantId: productVariantId ?? this.productVariantId,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    totalPrice: totalPrice ?? this.totalPrice,
    notes: notes.present ? notes.value : this.notes,
  );
  LocalQuoteItem copyWithCompanion(LocalQuoteItemsCompanion data) {
    return LocalQuoteItem(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      quoteId: data.quoteId.present ? data.quoteId.value : this.quoteId,
      productVariantId: data.productVariantId.present
          ? data.productVariantId.value
          : this.productVariantId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      totalPrice: data.totalPrice.present
          ? data.totalPrice.value
          : this.totalPrice,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuoteItem(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('quoteId: $quoteId, ')
          ..write('productVariantId: $productVariantId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    quoteId,
    productVariantId,
    quantity,
    unitPrice,
    totalPrice,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalQuoteItem &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.quoteId == this.quoteId &&
          other.productVariantId == this.productVariantId &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.totalPrice == this.totalPrice &&
          other.notes == this.notes);
}

class LocalQuoteItemsCompanion extends UpdateCompanion<LocalQuoteItem> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> quoteId;
  final Value<String> productVariantId;
  final Value<double> quantity;
  final Value<double> unitPrice;
  final Value<double> totalPrice;
  final Value<String?> notes;
  final Value<int> rowid;
  const LocalQuoteItemsCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.quoteId = const Value.absent(),
    this.productVariantId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalQuoteItemsCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String quoteId,
    required String productVariantId,
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : quoteId = Value(quoteId),
       productVariantId = Value(productVariantId);
  static Insertable<LocalQuoteItem> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? quoteId,
    Expression<String>? productVariantId,
    Expression<double>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? totalPrice,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (quoteId != null) 'quote_id': quoteId,
      if (productVariantId != null) 'product_variant_id': productVariantId,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (totalPrice != null) 'total_price': totalPrice,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalQuoteItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? quoteId,
    Value<String>? productVariantId,
    Value<double>? quantity,
    Value<double>? unitPrice,
    Value<double>? totalPrice,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return LocalQuoteItemsCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      quoteId: quoteId ?? this.quoteId,
      productVariantId: productVariantId ?? this.productVariantId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (quoteId.present) {
      map['quote_id'] = Variable<String>(quoteId.value);
    }
    if (productVariantId.present) {
      map['product_variant_id'] = Variable<String>(productVariantId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (totalPrice.present) {
      map['total_price'] = Variable<double>(totalPrice.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuoteItemsCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('quoteId: $quoteId, ')
          ..write('productVariantId: $productVariantId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalInvoicesTable extends LocalInvoices
    with TableInfo<$LocalInvoicesTable, LocalInvoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalInvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _invoiceNumberMeta = const VerificationMeta(
    'invoiceNumber',
  );
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
    'invoice_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _invoiceTypeMeta = const VerificationMeta(
    'invoiceType',
  );
  @override
  late final GeneratedColumn<String> invoiceType = GeneratedColumn<String>(
    'invoice_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('sale'),
  );
  static const VerificationMeta _originalInvoiceIdMeta = const VerificationMeta(
    'originalInvoiceId',
  );
  @override
  late final GeneratedColumn<String> originalInvoiceId =
      GeneratedColumn<String>(
        'original_invoice_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _amountPaidMeta = const VerificationMeta(
    'amountPaid',
  );
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
    'amount_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _taxAmountMeta = const VerificationMeta(
    'taxAmount',
  );
  @override
  late final GeneratedColumn<double> taxAmount = GeneratedColumn<double>(
    'tax_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _discountAmountMeta = const VerificationMeta(
    'discountAmount',
  );
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
    'discount_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confirmedAtMeta = const VerificationMeta(
    'confirmedAt',
  );
  @override
  late final GeneratedColumn<DateTime> confirmedAt = GeneratedColumn<DateTime>(
    'confirmed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    invoiceNumber,
    customerId,
    status,
    invoiceType,
    originalInvoiceId,
    totalAmount,
    amountPaid,
    taxAmount,
    discountAmount,
    notes,
    dueDate,
    confirmedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalInvoice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
        _invoiceNumberMeta,
        invoiceNumber.isAcceptableOrUnknown(
          data['invoice_number']!,
          _invoiceNumberMeta,
        ),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('invoice_type')) {
      context.handle(
        _invoiceTypeMeta,
        invoiceType.isAcceptableOrUnknown(
          data['invoice_type']!,
          _invoiceTypeMeta,
        ),
      );
    }
    if (data.containsKey('original_invoice_id')) {
      context.handle(
        _originalInvoiceIdMeta,
        originalInvoiceId.isAcceptableOrUnknown(
          data['original_invoice_id']!,
          _originalInvoiceIdMeta,
        ),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
        _amountPaidMeta,
        amountPaid.isAcceptableOrUnknown(data['amount_paid']!, _amountPaidMeta),
      );
    }
    if (data.containsKey('tax_amount')) {
      context.handle(
        _taxAmountMeta,
        taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta),
      );
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
        _discountAmountMeta,
        discountAmount.isAcceptableOrUnknown(
          data['discount_amount']!,
          _discountAmountMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('confirmed_at')) {
      context.handle(
        _confirmedAtMeta,
        confirmedAt.isAcceptableOrUnknown(
          data['confirmed_at']!,
          _confirmedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalInvoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalInvoice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      invoiceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_number'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      invoiceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_type'],
      )!,
      originalInvoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_invoice_id'],
      ),
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      amountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_paid'],
      )!,
      taxAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_amount'],
      )!,
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_amount'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      confirmedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}confirmed_at'],
      ),
    );
  }

  @override
  $LocalInvoicesTable createAlias(String alias) {
    return $LocalInvoicesTable(attachedDatabase, alias);
  }
}

class LocalInvoice extends DataClass implements Insertable<LocalInvoice> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? invoiceNumber;
  final String? customerId;
  final String status;
  final String invoiceType;
  final String? originalInvoiceId;
  final double totalAmount;
  final double amountPaid;
  final double taxAmount;
  final double discountAmount;
  final String? notes;
  final DateTime? dueDate;

  /// تاريخ اعتماد الفاتورة (يُملأ عند confirmInvoice)
  final DateTime? confirmedAt;
  const LocalInvoice({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.invoiceNumber,
    this.customerId,
    required this.status,
    required this.invoiceType,
    this.originalInvoiceId,
    required this.totalAmount,
    required this.amountPaid,
    required this.taxAmount,
    required this.discountAmount,
    this.notes,
    this.dueDate,
    this.confirmedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || invoiceNumber != null) {
      map['invoice_number'] = Variable<String>(invoiceNumber);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['status'] = Variable<String>(status);
    map['invoice_type'] = Variable<String>(invoiceType);
    if (!nullToAbsent || originalInvoiceId != null) {
      map['original_invoice_id'] = Variable<String>(originalInvoiceId);
    }
    map['total_amount'] = Variable<double>(totalAmount);
    map['amount_paid'] = Variable<double>(amountPaid);
    map['tax_amount'] = Variable<double>(taxAmount);
    map['discount_amount'] = Variable<double>(discountAmount);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || confirmedAt != null) {
      map['confirmed_at'] = Variable<DateTime>(confirmedAt);
    }
    return map;
  }

  LocalInvoicesCompanion toCompanion(bool nullToAbsent) {
    return LocalInvoicesCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      invoiceNumber: invoiceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceNumber),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      status: Value(status),
      invoiceType: Value(invoiceType),
      originalInvoiceId: originalInvoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originalInvoiceId),
      totalAmount: Value(totalAmount),
      amountPaid: Value(amountPaid),
      taxAmount: Value(taxAmount),
      discountAmount: Value(discountAmount),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      confirmedAt: confirmedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(confirmedAt),
    );
  }

  factory LocalInvoice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalInvoice(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      invoiceNumber: serializer.fromJson<String?>(json['invoiceNumber']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      status: serializer.fromJson<String>(json['status']),
      invoiceType: serializer.fromJson<String>(json['invoiceType']),
      originalInvoiceId: serializer.fromJson<String?>(
        json['originalInvoiceId'],
      ),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      taxAmount: serializer.fromJson<double>(json['taxAmount']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      notes: serializer.fromJson<String?>(json['notes']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      confirmedAt: serializer.fromJson<DateTime?>(json['confirmedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'invoiceNumber': serializer.toJson<String?>(invoiceNumber),
      'customerId': serializer.toJson<String?>(customerId),
      'status': serializer.toJson<String>(status),
      'invoiceType': serializer.toJson<String>(invoiceType),
      'originalInvoiceId': serializer.toJson<String?>(originalInvoiceId),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'taxAmount': serializer.toJson<double>(taxAmount),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'notes': serializer.toJson<String?>(notes),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'confirmedAt': serializer.toJson<DateTime?>(confirmedAt),
    };
  }

  LocalInvoice copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> invoiceNumber = const Value.absent(),
    Value<String?> customerId = const Value.absent(),
    String? status,
    String? invoiceType,
    Value<String?> originalInvoiceId = const Value.absent(),
    double? totalAmount,
    double? amountPaid,
    double? taxAmount,
    double? discountAmount,
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
    Value<DateTime?> confirmedAt = const Value.absent(),
  }) => LocalInvoice(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    invoiceNumber: invoiceNumber.present
        ? invoiceNumber.value
        : this.invoiceNumber,
    customerId: customerId.present ? customerId.value : this.customerId,
    status: status ?? this.status,
    invoiceType: invoiceType ?? this.invoiceType,
    originalInvoiceId: originalInvoiceId.present
        ? originalInvoiceId.value
        : this.originalInvoiceId,
    totalAmount: totalAmount ?? this.totalAmount,
    amountPaid: amountPaid ?? this.amountPaid,
    taxAmount: taxAmount ?? this.taxAmount,
    discountAmount: discountAmount ?? this.discountAmount,
    notes: notes.present ? notes.value : this.notes,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    confirmedAt: confirmedAt.present ? confirmedAt.value : this.confirmedAt,
  );
  LocalInvoice copyWithCompanion(LocalInvoicesCompanion data) {
    return LocalInvoice(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      status: data.status.present ? data.status.value : this.status,
      invoiceType: data.invoiceType.present
          ? data.invoiceType.value
          : this.invoiceType,
      originalInvoiceId: data.originalInvoiceId.present
          ? data.originalInvoiceId.value
          : this.originalInvoiceId,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      amountPaid: data.amountPaid.present
          ? data.amountPaid.value
          : this.amountPaid,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      notes: data.notes.present ? data.notes.value : this.notes,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      confirmedAt: data.confirmedAt.present
          ? data.confirmedAt.value
          : this.confirmedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalInvoice(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('customerId: $customerId, ')
          ..write('status: $status, ')
          ..write('invoiceType: $invoiceType, ')
          ..write('originalInvoiceId: $originalInvoiceId, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('notes: $notes, ')
          ..write('dueDate: $dueDate, ')
          ..write('confirmedAt: $confirmedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    invoiceNumber,
    customerId,
    status,
    invoiceType,
    originalInvoiceId,
    totalAmount,
    amountPaid,
    taxAmount,
    discountAmount,
    notes,
    dueDate,
    confirmedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalInvoice &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.invoiceNumber == this.invoiceNumber &&
          other.customerId == this.customerId &&
          other.status == this.status &&
          other.invoiceType == this.invoiceType &&
          other.originalInvoiceId == this.originalInvoiceId &&
          other.totalAmount == this.totalAmount &&
          other.amountPaid == this.amountPaid &&
          other.taxAmount == this.taxAmount &&
          other.discountAmount == this.discountAmount &&
          other.notes == this.notes &&
          other.dueDate == this.dueDate &&
          other.confirmedAt == this.confirmedAt);
}

class LocalInvoicesCompanion extends UpdateCompanion<LocalInvoice> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> invoiceNumber;
  final Value<String?> customerId;
  final Value<String> status;
  final Value<String> invoiceType;
  final Value<String?> originalInvoiceId;
  final Value<double> totalAmount;
  final Value<double> amountPaid;
  final Value<double> taxAmount;
  final Value<double> discountAmount;
  final Value<String?> notes;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> confirmedAt;
  final Value<int> rowid;
  const LocalInvoicesCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.customerId = const Value.absent(),
    this.status = const Value.absent(),
    this.invoiceType = const Value.absent(),
    this.originalInvoiceId = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.notes = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalInvoicesCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.customerId = const Value.absent(),
    this.status = const Value.absent(),
    this.invoiceType = const Value.absent(),
    this.originalInvoiceId = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.notes = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<LocalInvoice> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? invoiceNumber,
    Expression<String>? customerId,
    Expression<String>? status,
    Expression<String>? invoiceType,
    Expression<String>? originalInvoiceId,
    Expression<double>? totalAmount,
    Expression<double>? amountPaid,
    Expression<double>? taxAmount,
    Expression<double>? discountAmount,
    Expression<String>? notes,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? confirmedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (customerId != null) 'customer_id': customerId,
      if (status != null) 'status': status,
      if (invoiceType != null) 'invoice_type': invoiceType,
      if (originalInvoiceId != null) 'original_invoice_id': originalInvoiceId,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (notes != null) 'notes': notes,
      if (dueDate != null) 'due_date': dueDate,
      if (confirmedAt != null) 'confirmed_at': confirmedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalInvoicesCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? invoiceNumber,
    Value<String?>? customerId,
    Value<String>? status,
    Value<String>? invoiceType,
    Value<String?>? originalInvoiceId,
    Value<double>? totalAmount,
    Value<double>? amountPaid,
    Value<double>? taxAmount,
    Value<double>? discountAmount,
    Value<String?>? notes,
    Value<DateTime?>? dueDate,
    Value<DateTime?>? confirmedAt,
    Value<int>? rowid,
  }) {
    return LocalInvoicesCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      invoiceType: invoiceType ?? this.invoiceType,
      originalInvoiceId: originalInvoiceId ?? this.originalInvoiceId,
      totalAmount: totalAmount ?? this.totalAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      notes: notes ?? this.notes,
      dueDate: dueDate ?? this.dueDate,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (invoiceType.present) {
      map['invoice_type'] = Variable<String>(invoiceType.value);
    }
    if (originalInvoiceId.present) {
      map['original_invoice_id'] = Variable<String>(originalInvoiceId.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<double>(taxAmount.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (confirmedAt.present) {
      map['confirmed_at'] = Variable<DateTime>(confirmedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalInvoicesCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('customerId: $customerId, ')
          ..write('status: $status, ')
          ..write('invoiceType: $invoiceType, ')
          ..write('originalInvoiceId: $originalInvoiceId, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('notes: $notes, ')
          ..write('dueDate: $dueDate, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalInvoiceItemsTable extends LocalInvoiceItems
    with TableInfo<$LocalInvoiceItemsTable, LocalInvoiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalInvoiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productVariantIdMeta = const VerificationMeta(
    'productVariantId',
  );
  @override
  late final GeneratedColumn<String> productVariantId = GeneratedColumn<String>(
    'product_variant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalPriceMeta = const VerificationMeta(
    'totalPrice',
  );
  @override
  late final GeneratedColumn<double> totalPrice = GeneratedColumn<double>(
    'total_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    invoiceId,
    productVariantId,
    quantity,
    unitPrice,
    totalPrice,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_invoice_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalInvoiceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('product_variant_id')) {
      context.handle(
        _productVariantIdMeta,
        productVariantId.isAcceptableOrUnknown(
          data['product_variant_id']!,
          _productVariantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productVariantIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    }
    if (data.containsKey('total_price')) {
      context.handle(
        _totalPriceMeta,
        totalPrice.isAcceptableOrUnknown(data['total_price']!, _totalPriceMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalInvoiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalInvoiceItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      )!,
      productVariantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_variant_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      totalPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_price'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $LocalInvoiceItemsTable createAlias(String alias) {
    return $LocalInvoiceItemsTable(attachedDatabase, alias);
  }
}

class LocalInvoiceItem extends DataClass
    implements Insertable<LocalInvoiceItem> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String invoiceId;
  final String productVariantId;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;
  const LocalInvoiceItem({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.invoiceId,
    required this.productVariantId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['product_variant_id'] = Variable<String>(productVariantId);
    map['quantity'] = Variable<double>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['total_price'] = Variable<double>(totalPrice);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  LocalInvoiceItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalInvoiceItemsCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      invoiceId: Value(invoiceId),
      productVariantId: Value(productVariantId),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      totalPrice: Value(totalPrice),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory LocalInvoiceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalInvoiceItem(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      productVariantId: serializer.fromJson<String>(json['productVariantId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      totalPrice: serializer.fromJson<double>(json['totalPrice']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'productVariantId': serializer.toJson<String>(productVariantId),
      'quantity': serializer.toJson<double>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'totalPrice': serializer.toJson<double>(totalPrice),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LocalInvoiceItem copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? invoiceId,
    String? productVariantId,
    double? quantity,
    double? unitPrice,
    double? totalPrice,
    Value<String?> notes = const Value.absent(),
  }) => LocalInvoiceItem(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    invoiceId: invoiceId ?? this.invoiceId,
    productVariantId: productVariantId ?? this.productVariantId,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    totalPrice: totalPrice ?? this.totalPrice,
    notes: notes.present ? notes.value : this.notes,
  );
  LocalInvoiceItem copyWithCompanion(LocalInvoiceItemsCompanion data) {
    return LocalInvoiceItem(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      productVariantId: data.productVariantId.present
          ? data.productVariantId.value
          : this.productVariantId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      totalPrice: data.totalPrice.present
          ? data.totalPrice.value
          : this.totalPrice,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalInvoiceItem(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productVariantId: $productVariantId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    invoiceId,
    productVariantId,
    quantity,
    unitPrice,
    totalPrice,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalInvoiceItem &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.invoiceId == this.invoiceId &&
          other.productVariantId == this.productVariantId &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.totalPrice == this.totalPrice &&
          other.notes == this.notes);
}

class LocalInvoiceItemsCompanion extends UpdateCompanion<LocalInvoiceItem> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> invoiceId;
  final Value<String> productVariantId;
  final Value<double> quantity;
  final Value<double> unitPrice;
  final Value<double> totalPrice;
  final Value<String?> notes;
  final Value<int> rowid;
  const LocalInvoiceItemsCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.productVariantId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalInvoiceItemsCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String invoiceId,
    required String productVariantId,
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : invoiceId = Value(invoiceId),
       productVariantId = Value(productVariantId);
  static Insertable<LocalInvoiceItem> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? invoiceId,
    Expression<String>? productVariantId,
    Expression<double>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? totalPrice,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (productVariantId != null) 'product_variant_id': productVariantId,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (totalPrice != null) 'total_price': totalPrice,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalInvoiceItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? invoiceId,
    Value<String>? productVariantId,
    Value<double>? quantity,
    Value<double>? unitPrice,
    Value<double>? totalPrice,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return LocalInvoiceItemsCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      invoiceId: invoiceId ?? this.invoiceId,
      productVariantId: productVariantId ?? this.productVariantId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (productVariantId.present) {
      map['product_variant_id'] = Variable<String>(productVariantId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (totalPrice.present) {
      map['total_price'] = Variable<double>(totalPrice.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalInvoiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productVariantId: $productVariantId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCustomersTable extends LocalCustomers
    with TableInfo<$LocalCustomersTable, LocalCustomer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    name,
    phone,
    address,
    type,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCustomer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCustomer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCustomer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $LocalCustomersTable createAlias(String alias) {
    return $LocalCustomersTable(attachedDatabase, alias);
  }
}

class LocalCustomer extends DataClass implements Insertable<LocalCustomer> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final String? phone;
  final String? address;
  final String? type;
  final String? notes;
  const LocalCustomer({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    this.phone,
    this.address,
    this.type,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  LocalCustomersCompanion toCompanion(bool nullToAbsent) {
    return LocalCustomersCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory LocalCustomer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCustomer(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      type: serializer.fromJson<String?>(json['type']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
      'type': serializer.toJson<String?>(type),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LocalCustomer copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> type = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => LocalCustomer(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    address: address.present ? address.value : this.address,
    type: type.present ? type.value : this.type,
    notes: notes.present ? notes.value : this.notes,
  );
  LocalCustomer copyWithCompanion(LocalCustomersCompanion data) {
    return LocalCustomer(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      type: data.type.present ? data.type.value : this.type,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCustomer(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('type: $type, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    name,
    phone,
    address,
    type,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCustomer &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.type == this.type &&
          other.notes == this.notes);
}

class LocalCustomersCompanion extends UpdateCompanion<LocalCustomer> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<String?> type;
  final Value<String?> notes;
  final Value<int> rowid;
  const LocalCustomersCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.type = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCustomersCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.type = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<LocalCustomer> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? type,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (type != null) 'type': type,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? address,
    Value<String?>? type,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return LocalCustomersCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCustomersCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('type: $type, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalProductPresetsTable extends LocalProductPresets
    with TableInfo<$LocalProductPresetsTable, LocalProductPreset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProductPresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _productVariantIdMeta = const VerificationMeta(
    'productVariantId',
  );
  @override
  late final GeneratedColumn<String> productVariantId = GeneratedColumn<String>(
    'product_variant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presetDataMeta = const VerificationMeta(
    'presetData',
  );
  @override
  late final GeneratedColumn<String> presetData = GeneratedColumn<String>(
    'preset_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    productVariantId,
    name,
    presetData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_product_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalProductPreset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('product_variant_id')) {
      context.handle(
        _productVariantIdMeta,
        productVariantId.isAcceptableOrUnknown(
          data['product_variant_id']!,
          _productVariantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productVariantIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('preset_data')) {
      context.handle(
        _presetDataMeta,
        presetData.isAcceptableOrUnknown(data['preset_data']!, _presetDataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalProductPreset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProductPreset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      productVariantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_variant_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      presetData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset_data'],
      ),
    );
  }

  @override
  $LocalProductPresetsTable createAlias(String alias) {
    return $LocalProductPresetsTable(attachedDatabase, alias);
  }
}

class LocalProductPreset extends DataClass
    implements Insertable<LocalProductPreset> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String productVariantId;
  final String name;
  final String? presetData;
  const LocalProductPreset({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.productVariantId,
    required this.name,
    this.presetData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['product_variant_id'] = Variable<String>(productVariantId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || presetData != null) {
      map['preset_data'] = Variable<String>(presetData);
    }
    return map;
  }

  LocalProductPresetsCompanion toCompanion(bool nullToAbsent) {
    return LocalProductPresetsCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      productVariantId: Value(productVariantId),
      name: Value(name),
      presetData: presetData == null && nullToAbsent
          ? const Value.absent()
          : Value(presetData),
    );
  }

  factory LocalProductPreset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProductPreset(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      productVariantId: serializer.fromJson<String>(json['productVariantId']),
      name: serializer.fromJson<String>(json['name']),
      presetData: serializer.fromJson<String?>(json['presetData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'productVariantId': serializer.toJson<String>(productVariantId),
      'name': serializer.toJson<String>(name),
      'presetData': serializer.toJson<String?>(presetData),
    };
  }

  LocalProductPreset copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? productVariantId,
    String? name,
    Value<String?> presetData = const Value.absent(),
  }) => LocalProductPreset(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    productVariantId: productVariantId ?? this.productVariantId,
    name: name ?? this.name,
    presetData: presetData.present ? presetData.value : this.presetData,
  );
  LocalProductPreset copyWithCompanion(LocalProductPresetsCompanion data) {
    return LocalProductPreset(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      productVariantId: data.productVariantId.present
          ? data.productVariantId.value
          : this.productVariantId,
      name: data.name.present ? data.name.value : this.name,
      presetData: data.presetData.present
          ? data.presetData.value
          : this.presetData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProductPreset(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('productVariantId: $productVariantId, ')
          ..write('name: $name, ')
          ..write('presetData: $presetData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    productVariantId,
    name,
    presetData,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProductPreset &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.productVariantId == this.productVariantId &&
          other.name == this.name &&
          other.presetData == this.presetData);
}

class LocalProductPresetsCompanion extends UpdateCompanion<LocalProductPreset> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> productVariantId;
  final Value<String> name;
  final Value<String?> presetData;
  final Value<int> rowid;
  const LocalProductPresetsCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.productVariantId = const Value.absent(),
    this.name = const Value.absent(),
    this.presetData = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProductPresetsCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String productVariantId,
    required String name,
    this.presetData = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : productVariantId = Value(productVariantId),
       name = Value(name);
  static Insertable<LocalProductPreset> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? productVariantId,
    Expression<String>? name,
    Expression<String>? presetData,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (productVariantId != null) 'product_variant_id': productVariantId,
      if (name != null) 'name': name,
      if (presetData != null) 'preset_data': presetData,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProductPresetsCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? productVariantId,
    Value<String>? name,
    Value<String?>? presetData,
    Value<int>? rowid,
  }) {
    return LocalProductPresetsCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productVariantId: productVariantId ?? this.productVariantId,
      name: name ?? this.name,
      presetData: presetData ?? this.presetData,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (productVariantId.present) {
      map['product_variant_id'] = Variable<String>(productVariantId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (presetData.present) {
      map['preset_data'] = Variable<String>(presetData.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProductPresetsCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('productVariantId: $productVariantId, ')
          ..write('name: $name, ')
          ..write('presetData: $presetData, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalProductAssembliesTable extends LocalProductAssemblies
    with TableInfo<$LocalProductAssembliesTable, LocalProductAssembly> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProductAssembliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _productVariantIdMeta = const VerificationMeta(
    'productVariantId',
  );
  @override
  late final GeneratedColumn<String> productVariantId = GeneratedColumn<String>(
    'product_variant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accessoryProductIdMeta =
      const VerificationMeta('accessoryProductId');
  @override
  late final GeneratedColumn<String> accessoryProductId =
      GeneratedColumn<String>(
        'accessory_product_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    productVariantId,
    accessoryProductId,
    quantity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_product_assemblies';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalProductAssembly> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('product_variant_id')) {
      context.handle(
        _productVariantIdMeta,
        productVariantId.isAcceptableOrUnknown(
          data['product_variant_id']!,
          _productVariantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productVariantIdMeta);
    }
    if (data.containsKey('accessory_product_id')) {
      context.handle(
        _accessoryProductIdMeta,
        accessoryProductId.isAcceptableOrUnknown(
          data['accessory_product_id']!,
          _accessoryProductIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accessoryProductIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalProductAssembly map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProductAssembly(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      productVariantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_variant_id'],
      )!,
      accessoryProductId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accessory_product_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $LocalProductAssembliesTable createAlias(String alias) {
    return $LocalProductAssembliesTable(attachedDatabase, alias);
  }
}

class LocalProductAssembly extends DataClass
    implements Insertable<LocalProductAssembly> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String productVariantId;
  final String accessoryProductId;
  final double quantity;
  const LocalProductAssembly({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.productVariantId,
    required this.accessoryProductId,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['product_variant_id'] = Variable<String>(productVariantId);
    map['accessory_product_id'] = Variable<String>(accessoryProductId);
    map['quantity'] = Variable<double>(quantity);
    return map;
  }

  LocalProductAssembliesCompanion toCompanion(bool nullToAbsent) {
    return LocalProductAssembliesCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      productVariantId: Value(productVariantId),
      accessoryProductId: Value(accessoryProductId),
      quantity: Value(quantity),
    );
  }

  factory LocalProductAssembly.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProductAssembly(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      productVariantId: serializer.fromJson<String>(json['productVariantId']),
      accessoryProductId: serializer.fromJson<String>(
        json['accessoryProductId'],
      ),
      quantity: serializer.fromJson<double>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'productVariantId': serializer.toJson<String>(productVariantId),
      'accessoryProductId': serializer.toJson<String>(accessoryProductId),
      'quantity': serializer.toJson<double>(quantity),
    };
  }

  LocalProductAssembly copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? productVariantId,
    String? accessoryProductId,
    double? quantity,
  }) => LocalProductAssembly(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    productVariantId: productVariantId ?? this.productVariantId,
    accessoryProductId: accessoryProductId ?? this.accessoryProductId,
    quantity: quantity ?? this.quantity,
  );
  LocalProductAssembly copyWithCompanion(LocalProductAssembliesCompanion data) {
    return LocalProductAssembly(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      productVariantId: data.productVariantId.present
          ? data.productVariantId.value
          : this.productVariantId,
      accessoryProductId: data.accessoryProductId.present
          ? data.accessoryProductId.value
          : this.accessoryProductId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProductAssembly(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('productVariantId: $productVariantId, ')
          ..write('accessoryProductId: $accessoryProductId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    productVariantId,
    accessoryProductId,
    quantity,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProductAssembly &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.productVariantId == this.productVariantId &&
          other.accessoryProductId == this.accessoryProductId &&
          other.quantity == this.quantity);
}

class LocalProductAssembliesCompanion
    extends UpdateCompanion<LocalProductAssembly> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> productVariantId;
  final Value<String> accessoryProductId;
  final Value<double> quantity;
  final Value<int> rowid;
  const LocalProductAssembliesCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.productVariantId = const Value.absent(),
    this.accessoryProductId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProductAssembliesCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String productVariantId,
    required String accessoryProductId,
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : productVariantId = Value(productVariantId),
       accessoryProductId = Value(accessoryProductId);
  static Insertable<LocalProductAssembly> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? productVariantId,
    Expression<String>? accessoryProductId,
    Expression<double>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (productVariantId != null) 'product_variant_id': productVariantId,
      if (accessoryProductId != null)
        'accessory_product_id': accessoryProductId,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProductAssembliesCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? productVariantId,
    Value<String>? accessoryProductId,
    Value<double>? quantity,
    Value<int>? rowid,
  }) {
    return LocalProductAssembliesCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productVariantId: productVariantId ?? this.productVariantId,
      accessoryProductId: accessoryProductId ?? this.accessoryProductId,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (productVariantId.present) {
      map['product_variant_id'] = Variable<String>(productVariantId.value);
    }
    if (accessoryProductId.present) {
      map['accessory_product_id'] = Variable<String>(accessoryProductId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProductAssembliesCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('productVariantId: $productVariantId, ')
          ..write('accessoryProductId: $accessoryProductId, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalProfilesTable extends LocalProfiles
    with TableInfo<$LocalProfilesTable, LocalProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('seller'),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shopNameMeta = const VerificationMeta(
    'shopName',
  );
  @override
  late final GeneratedColumn<String> shopName = GeneratedColumn<String>(
    'shop_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    fullName,
    role,
    phone,
    shopName,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('shop_name')) {
      context.handle(
        _shopNameMeta,
        shopName.isAcceptableOrUnknown(data['shop_name']!, _shopNameMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      shopName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_name'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $LocalProfilesTable createAlias(String alias) {
    return $LocalProfilesTable(attachedDatabase, alias);
  }
}

class LocalProfile extends DataClass implements Insertable<LocalProfile> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fullName;
  final String role;
  final String? phone;
  final String? shopName;
  final bool isActive;
  const LocalProfile({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.fullName,
    required this.role,
    this.phone,
    this.shopName,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || shopName != null) {
      map['shop_name'] = Variable<String>(shopName);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  LocalProfilesCompanion toCompanion(bool nullToAbsent) {
    return LocalProfilesCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      role: Value(role),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      shopName: shopName == null && nullToAbsent
          ? const Value.absent()
          : Value(shopName),
      isActive: Value(isActive),
    );
  }

  factory LocalProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProfile(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      role: serializer.fromJson<String>(json['role']),
      phone: serializer.fromJson<String?>(json['phone']),
      shopName: serializer.fromJson<String?>(json['shopName']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'fullName': serializer.toJson<String?>(fullName),
      'role': serializer.toJson<String>(role),
      'phone': serializer.toJson<String?>(phone),
      'shopName': serializer.toJson<String?>(shopName),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  LocalProfile copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> fullName = const Value.absent(),
    String? role,
    Value<String?> phone = const Value.absent(),
    Value<String?> shopName = const Value.absent(),
    bool? isActive,
  }) => LocalProfile(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    fullName: fullName.present ? fullName.value : this.fullName,
    role: role ?? this.role,
    phone: phone.present ? phone.value : this.phone,
    shopName: shopName.present ? shopName.value : this.shopName,
    isActive: isActive ?? this.isActive,
  );
  LocalProfile copyWithCompanion(LocalProfilesCompanion data) {
    return LocalProfile(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      role: data.role.present ? data.role.value : this.role,
      phone: data.phone.present ? data.phone.value : this.phone,
      shopName: data.shopName.present ? data.shopName.value : this.shopName,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfile(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('fullName: $fullName, ')
          ..write('role: $role, ')
          ..write('phone: $phone, ')
          ..write('shopName: $shopName, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    fullName,
    role,
    phone,
    shopName,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProfile &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.fullName == this.fullName &&
          other.role == this.role &&
          other.phone == this.phone &&
          other.shopName == this.shopName &&
          other.isActive == this.isActive);
}

class LocalProfilesCompanion extends UpdateCompanion<LocalProfile> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> fullName;
  final Value<String> role;
  final Value<String?> phone;
  final Value<String?> shopName;
  final Value<bool> isActive;
  final Value<int> rowid;
  const LocalProfilesCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.fullName = const Value.absent(),
    this.role = const Value.absent(),
    this.phone = const Value.absent(),
    this.shopName = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.fullName = const Value.absent(),
    this.role = const Value.absent(),
    this.phone = const Value.absent(),
    this.shopName = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<LocalProfile> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? fullName,
    Expression<String>? role,
    Expression<String>? phone,
    Expression<String>? shopName,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (fullName != null) 'full_name': fullName,
      if (role != null) 'role': role,
      if (phone != null) 'phone': phone,
      if (shopName != null) 'shop_name': shopName,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? fullName,
    Value<String>? role,
    Value<String?>? phone,
    Value<String?>? shopName,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return LocalProfilesCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      shopName: shopName ?? this.shopName,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (shopName.present) {
      map['shop_name'] = Variable<String>(shopName.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfilesCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('fullName: $fullName, ')
          ..write('role: $role, ')
          ..write('phone: $phone, ')
          ..write('shopName: $shopName, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPaymentsTable extends LocalPayments
    with TableInfo<$LocalPaymentsTable, LocalPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('cash'),
  );
  static const VerificationMeta _referenceNumberMeta = const VerificationMeta(
    'referenceNumber',
  );
  @override
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
    'reference_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    invoiceId,
    customerId,
    amount,
    paymentMethod,
    referenceNumber,
    notes,
    createdBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('reference_number')) {
      context.handle(
        _referenceNumberMeta,
        referenceNumber.isAcceptableOrUnknown(
          data['reference_number']!,
          _referenceNumberMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      referenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_number'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
    );
  }

  @override
  $LocalPaymentsTable createAlias(String alias) {
    return $LocalPaymentsTable(attachedDatabase, alias);
  }
}

class LocalPayment extends DataClass implements Insertable<LocalPayment> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String invoiceId;
  final String? customerId;
  final double amount;
  final String paymentMethod;
  final String? referenceNumber;
  final String? notes;
  final String? createdBy;
  const LocalPayment({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.invoiceId,
    this.customerId,
    required this.amount,
    required this.paymentMethod,
    this.referenceNumber,
    this.notes,
    this.createdBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['invoice_id'] = Variable<String>(invoiceId);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['amount'] = Variable<double>(amount);
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || referenceNumber != null) {
      map['reference_number'] = Variable<String>(referenceNumber);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    return map;
  }

  LocalPaymentsCompanion toCompanion(bool nullToAbsent) {
    return LocalPaymentsCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      invoiceId: Value(invoiceId),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      amount: Value(amount),
      paymentMethod: Value(paymentMethod),
      referenceNumber: referenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNumber),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
    );
  }

  factory LocalPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPayment(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      referenceNumber: serializer.fromJson<String?>(json['referenceNumber']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'customerId': serializer.toJson<String?>(customerId),
      'amount': serializer.toJson<double>(amount),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'referenceNumber': serializer.toJson<String?>(referenceNumber),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String?>(createdBy),
    };
  }

  LocalPayment copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? invoiceId,
    Value<String?> customerId = const Value.absent(),
    double? amount,
    String? paymentMethod,
    Value<String?> referenceNumber = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
  }) => LocalPayment(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    invoiceId: invoiceId ?? this.invoiceId,
    customerId: customerId.present ? customerId.value : this.customerId,
    amount: amount ?? this.amount,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    referenceNumber: referenceNumber.present
        ? referenceNumber.value
        : this.referenceNumber,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
  );
  LocalPayment copyWithCompanion(LocalPaymentsCompanion data) {
    return LocalPayment(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      referenceNumber: data.referenceNumber.present
          ? data.referenceNumber.value
          : this.referenceNumber,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPayment(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('customerId: $customerId, ')
          ..write('amount: $amount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    invoiceId,
    customerId,
    amount,
    paymentMethod,
    referenceNumber,
    notes,
    createdBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPayment &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.invoiceId == this.invoiceId &&
          other.customerId == this.customerId &&
          other.amount == this.amount &&
          other.paymentMethod == this.paymentMethod &&
          other.referenceNumber == this.referenceNumber &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy);
}

class LocalPaymentsCompanion extends UpdateCompanion<LocalPayment> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> invoiceId;
  final Value<String?> customerId;
  final Value<double> amount;
  final Value<String> paymentMethod;
  final Value<String?> referenceNumber;
  final Value<String?> notes;
  final Value<String?> createdBy;
  final Value<int> rowid;
  const LocalPaymentsCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPaymentsCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String invoiceId,
    this.customerId = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : invoiceId = Value(invoiceId);
  static Insertable<LocalPayment> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? invoiceId,
    Expression<String>? customerId,
    Expression<double>? amount,
    Expression<String>? paymentMethod,
    Expression<String>? referenceNumber,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (customerId != null) 'customer_id': customerId,
      if (amount != null) 'amount': amount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? invoiceId,
    Value<String?>? customerId,
    Value<double>? amount,
    Value<String>? paymentMethod,
    Value<String?>? referenceNumber,
    Value<String?>? notes,
    Value<String?>? createdBy,
    Value<int>? rowid,
  }) {
    return LocalPaymentsCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      invoiceId: invoiceId ?? this.invoiceId,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('customerId: $customerId, ')
          ..write('amount: $amount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSystemLogsTable extends LocalSystemLogs
    with TableInfo<$LocalSystemLogsTable, LocalSystemLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSystemLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stackTraceMeta = const VerificationMeta(
    'stackTrace',
  );
  @override
  late final GeneratedColumn<String> stackTrace = GeneratedColumn<String>(
    'stack_trace',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contextMeta = const VerificationMeta(
    'context',
  );
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
    'context',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    level,
    message,
    error,
    stackTrace,
    context,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_system_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSystemLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('stack_trace')) {
      context.handle(
        _stackTraceMeta,
        stackTrace.isAcceptableOrUnknown(data['stack_trace']!, _stackTraceMeta),
      );
    }
    if (data.containsKey('context')) {
      context.handle(
        _contextMeta,
        this.context.isAcceptableOrUnknown(data['context']!, _contextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSystemLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSystemLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      stackTrace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stack_trace'],
      ),
      context: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context'],
      ),
    );
  }

  @override
  $LocalSystemLogsTable createAlias(String alias) {
    return $LocalSystemLogsTable(attachedDatabase, alias);
  }
}

class LocalSystemLog extends DataClass implements Insertable<LocalSystemLog> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String level;
  final String message;
  final String? error;
  final String? stackTrace;
  final String? context;
  const LocalSystemLog({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
    this.context,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['level'] = Variable<String>(level);
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    if (!nullToAbsent || stackTrace != null) {
      map['stack_trace'] = Variable<String>(stackTrace);
    }
    if (!nullToAbsent || context != null) {
      map['context'] = Variable<String>(context);
    }
    return map;
  }

  LocalSystemLogsCompanion toCompanion(bool nullToAbsent) {
    return LocalSystemLogsCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      level: Value(level),
      message: Value(message),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      stackTrace: stackTrace == null && nullToAbsent
          ? const Value.absent()
          : Value(stackTrace),
      context: context == null && nullToAbsent
          ? const Value.absent()
          : Value(context),
    );
  }

  factory LocalSystemLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSystemLog(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      level: serializer.fromJson<String>(json['level']),
      message: serializer.fromJson<String>(json['message']),
      error: serializer.fromJson<String?>(json['error']),
      stackTrace: serializer.fromJson<String?>(json['stackTrace']),
      context: serializer.fromJson<String?>(json['context']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'level': serializer.toJson<String>(level),
      'message': serializer.toJson<String>(message),
      'error': serializer.toJson<String?>(error),
      'stackTrace': serializer.toJson<String?>(stackTrace),
      'context': serializer.toJson<String?>(context),
    };
  }

  LocalSystemLog copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? level,
    String? message,
    Value<String?> error = const Value.absent(),
    Value<String?> stackTrace = const Value.absent(),
    Value<String?> context = const Value.absent(),
  }) => LocalSystemLog(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    level: level ?? this.level,
    message: message ?? this.message,
    error: error.present ? error.value : this.error,
    stackTrace: stackTrace.present ? stackTrace.value : this.stackTrace,
    context: context.present ? context.value : this.context,
  );
  LocalSystemLog copyWithCompanion(LocalSystemLogsCompanion data) {
    return LocalSystemLog(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      level: data.level.present ? data.level.value : this.level,
      message: data.message.present ? data.message.value : this.message,
      error: data.error.present ? data.error.value : this.error,
      stackTrace: data.stackTrace.present
          ? data.stackTrace.value
          : this.stackTrace,
      context: data.context.present ? data.context.value : this.context,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSystemLog(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('error: $error, ')
          ..write('stackTrace: $stackTrace, ')
          ..write('context: $context')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    level,
    message,
    error,
    stackTrace,
    context,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSystemLog &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.level == this.level &&
          other.message == this.message &&
          other.error == this.error &&
          other.stackTrace == this.stackTrace &&
          other.context == this.context);
}

class LocalSystemLogsCompanion extends UpdateCompanion<LocalSystemLog> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> level;
  final Value<String> message;
  final Value<String?> error;
  final Value<String?> stackTrace;
  final Value<String?> context;
  final Value<int> rowid;
  const LocalSystemLogsCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.level = const Value.absent(),
    this.message = const Value.absent(),
    this.error = const Value.absent(),
    this.stackTrace = const Value.absent(),
    this.context = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSystemLogsCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String level,
    required String message,
    this.error = const Value.absent(),
    this.stackTrace = const Value.absent(),
    this.context = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : level = Value(level),
       message = Value(message);
  static Insertable<LocalSystemLog> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? level,
    Expression<String>? message,
    Expression<String>? error,
    Expression<String>? stackTrace,
    Expression<String>? context,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (level != null) 'level': level,
      if (message != null) 'message': message,
      if (error != null) 'error': error,
      if (stackTrace != null) 'stack_trace': stackTrace,
      if (context != null) 'context': context,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSystemLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? level,
    Value<String>? message,
    Value<String?>? error,
    Value<String?>? stackTrace,
    Value<String?>? context,
    Value<int>? rowid,
  }) {
    return LocalSystemLogsCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      level: level ?? this.level,
      message: message ?? this.message,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      context: context ?? this.context,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (stackTrace.present) {
      map['stack_trace'] = Variable<String>(stackTrace.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSystemLogsCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('error: $error, ')
          ..write('stackTrace: $stackTrace, ')
          ..write('context: $context, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPricingRulesTable extends LocalPricingRules
    with TableInfo<$LocalPricingRulesTable, LocalPricingRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPricingRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_insert'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subcategoryMeta = const VerificationMeta(
    'subcategory',
  );
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
    'subcategory',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _materialMeta = const VerificationMeta(
    'material',
  );
  @override
  late final GeneratedColumn<String> material = GeneratedColumn<String>(
    'material',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _variantTypeMeta = const VerificationMeta(
    'variantType',
  );
  @override
  late final GeneratedColumn<String> variantType = GeneratedColumn<String>(
    'variant_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dimensionSpecMeta = const VerificationMeta(
    'dimensionSpec',
  );
  @override
  late final GeneratedColumn<String> dimensionSpec = GeneratedColumn<String>(
    'dimension_spec',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costPriceMeta = const VerificationMeta(
    'costPrice',
  );
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
    'cost_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sellingPriceMeta = const VerificationMeta(
    'sellingPrice',
  );
  @override
  late final GeneratedColumn<double> sellingPrice = GeneratedColumn<double>(
    'selling_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _technicianPriceMeta = const VerificationMeta(
    'technicianPrice',
  );
  @override
  late final GeneratedColumn<double> technicianPrice = GeneratedColumn<double>(
    'technician_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _minSellingPriceMeta = const VerificationMeta(
    'minSellingPrice',
  );
  @override
  late final GeneratedColumn<double> minSellingPrice = GeneratedColumn<double>(
    'min_selling_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    category,
    subcategory,
    material,
    variantType,
    dimensionSpec,
    costPrice,
    sellingPrice,
    technicianPrice,
    minSellingPrice,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_pricing_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPricingRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('subcategory')) {
      context.handle(
        _subcategoryMeta,
        subcategory.isAcceptableOrUnknown(
          data['subcategory']!,
          _subcategoryMeta,
        ),
      );
    }
    if (data.containsKey('material')) {
      context.handle(
        _materialMeta,
        material.isAcceptableOrUnknown(data['material']!, _materialMeta),
      );
    }
    if (data.containsKey('variant_type')) {
      context.handle(
        _variantTypeMeta,
        variantType.isAcceptableOrUnknown(
          data['variant_type']!,
          _variantTypeMeta,
        ),
      );
    }
    if (data.containsKey('dimension_spec')) {
      context.handle(
        _dimensionSpecMeta,
        dimensionSpec.isAcceptableOrUnknown(
          data['dimension_spec']!,
          _dimensionSpecMeta,
        ),
      );
    }
    if (data.containsKey('cost_price')) {
      context.handle(
        _costPriceMeta,
        costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta),
      );
    }
    if (data.containsKey('selling_price')) {
      context.handle(
        _sellingPriceMeta,
        sellingPrice.isAcceptableOrUnknown(
          data['selling_price']!,
          _sellingPriceMeta,
        ),
      );
    }
    if (data.containsKey('technician_price')) {
      context.handle(
        _technicianPriceMeta,
        technicianPrice.isAcceptableOrUnknown(
          data['technician_price']!,
          _technicianPriceMeta,
        ),
      );
    }
    if (data.containsKey('min_selling_price')) {
      context.handle(
        _minSellingPriceMeta,
        minSellingPrice.isAcceptableOrUnknown(
          data['min_selling_price']!,
          _minSellingPriceMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPricingRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPricingRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      subcategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subcategory'],
      ),
      material: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material'],
      ),
      variantType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_type'],
      ),
      dimensionSpec: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dimension_spec'],
      ),
      costPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_price'],
      )!,
      sellingPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}selling_price'],
      )!,
      technicianPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}technician_price'],
      )!,
      minSellingPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_selling_price'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $LocalPricingRulesTable createAlias(String alias) {
    return $LocalPricingRulesTable(attachedDatabase, alias);
  }
}

class LocalPricingRule extends DataClass
    implements Insertable<LocalPricingRule> {
  /// UUID primary key (matches Supabase id)
  final String id;

  /// Sync status: 'synced', 'pending_insert', 'pending_update', 'pending_delete'
  final String syncStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;
  final String? subcategory;
  final String? material;
  final String? variantType;
  final String? dimensionSpec;
  final double costPrice;
  final double sellingPrice;
  final double technicianPrice;
  final double minSellingPrice;
  final String? notes;
  const LocalPricingRule({
    required this.id,
    required this.syncStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    this.subcategory,
    this.material,
    this.variantType,
    this.dimensionSpec,
    required this.costPrice,
    required this.sellingPrice,
    required this.technicianPrice,
    required this.minSellingPrice,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || subcategory != null) {
      map['subcategory'] = Variable<String>(subcategory);
    }
    if (!nullToAbsent || material != null) {
      map['material'] = Variable<String>(material);
    }
    if (!nullToAbsent || variantType != null) {
      map['variant_type'] = Variable<String>(variantType);
    }
    if (!nullToAbsent || dimensionSpec != null) {
      map['dimension_spec'] = Variable<String>(dimensionSpec);
    }
    map['cost_price'] = Variable<double>(costPrice);
    map['selling_price'] = Variable<double>(sellingPrice);
    map['technician_price'] = Variable<double>(technicianPrice);
    map['min_selling_price'] = Variable<double>(minSellingPrice);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  LocalPricingRulesCompanion toCompanion(bool nullToAbsent) {
    return LocalPricingRulesCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      category: Value(category),
      subcategory: subcategory == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategory),
      material: material == null && nullToAbsent
          ? const Value.absent()
          : Value(material),
      variantType: variantType == null && nullToAbsent
          ? const Value.absent()
          : Value(variantType),
      dimensionSpec: dimensionSpec == null && nullToAbsent
          ? const Value.absent()
          : Value(dimensionSpec),
      costPrice: Value(costPrice),
      sellingPrice: Value(sellingPrice),
      technicianPrice: Value(technicianPrice),
      minSellingPrice: Value(minSellingPrice),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory LocalPricingRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPricingRule(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      category: serializer.fromJson<String>(json['category']),
      subcategory: serializer.fromJson<String?>(json['subcategory']),
      material: serializer.fromJson<String?>(json['material']),
      variantType: serializer.fromJson<String?>(json['variantType']),
      dimensionSpec: serializer.fromJson<String?>(json['dimensionSpec']),
      costPrice: serializer.fromJson<double>(json['costPrice']),
      sellingPrice: serializer.fromJson<double>(json['sellingPrice']),
      technicianPrice: serializer.fromJson<double>(json['technicianPrice']),
      minSellingPrice: serializer.fromJson<double>(json['minSellingPrice']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'category': serializer.toJson<String>(category),
      'subcategory': serializer.toJson<String?>(subcategory),
      'material': serializer.toJson<String?>(material),
      'variantType': serializer.toJson<String?>(variantType),
      'dimensionSpec': serializer.toJson<String?>(dimensionSpec),
      'costPrice': serializer.toJson<double>(costPrice),
      'sellingPrice': serializer.toJson<double>(sellingPrice),
      'technicianPrice': serializer.toJson<double>(technicianPrice),
      'minSellingPrice': serializer.toJson<double>(minSellingPrice),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LocalPricingRule copyWith({
    String? id,
    String? syncStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    Value<String?> subcategory = const Value.absent(),
    Value<String?> material = const Value.absent(),
    Value<String?> variantType = const Value.absent(),
    Value<String?> dimensionSpec = const Value.absent(),
    double? costPrice,
    double? sellingPrice,
    double? technicianPrice,
    double? minSellingPrice,
    Value<String?> notes = const Value.absent(),
  }) => LocalPricingRule(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    category: category ?? this.category,
    subcategory: subcategory.present ? subcategory.value : this.subcategory,
    material: material.present ? material.value : this.material,
    variantType: variantType.present ? variantType.value : this.variantType,
    dimensionSpec: dimensionSpec.present
        ? dimensionSpec.value
        : this.dimensionSpec,
    costPrice: costPrice ?? this.costPrice,
    sellingPrice: sellingPrice ?? this.sellingPrice,
    technicianPrice: technicianPrice ?? this.technicianPrice,
    minSellingPrice: minSellingPrice ?? this.minSellingPrice,
    notes: notes.present ? notes.value : this.notes,
  );
  LocalPricingRule copyWithCompanion(LocalPricingRulesCompanion data) {
    return LocalPricingRule(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      category: data.category.present ? data.category.value : this.category,
      subcategory: data.subcategory.present
          ? data.subcategory.value
          : this.subcategory,
      material: data.material.present ? data.material.value : this.material,
      variantType: data.variantType.present
          ? data.variantType.value
          : this.variantType,
      dimensionSpec: data.dimensionSpec.present
          ? data.dimensionSpec.value
          : this.dimensionSpec,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
      sellingPrice: data.sellingPrice.present
          ? data.sellingPrice.value
          : this.sellingPrice,
      technicianPrice: data.technicianPrice.present
          ? data.technicianPrice.value
          : this.technicianPrice,
      minSellingPrice: data.minSellingPrice.present
          ? data.minSellingPrice.value
          : this.minSellingPrice,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPricingRule(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('material: $material, ')
          ..write('variantType: $variantType, ')
          ..write('dimensionSpec: $dimensionSpec, ')
          ..write('costPrice: $costPrice, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('technicianPrice: $technicianPrice, ')
          ..write('minSellingPrice: $minSellingPrice, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    isDeleted,
    createdAt,
    updatedAt,
    category,
    subcategory,
    material,
    variantType,
    dimensionSpec,
    costPrice,
    sellingPrice,
    technicianPrice,
    minSellingPrice,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPricingRule &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.category == this.category &&
          other.subcategory == this.subcategory &&
          other.material == this.material &&
          other.variantType == this.variantType &&
          other.dimensionSpec == this.dimensionSpec &&
          other.costPrice == this.costPrice &&
          other.sellingPrice == this.sellingPrice &&
          other.technicianPrice == this.technicianPrice &&
          other.minSellingPrice == this.minSellingPrice &&
          other.notes == this.notes);
}

class LocalPricingRulesCompanion extends UpdateCompanion<LocalPricingRule> {
  final Value<String> id;
  final Value<String> syncStatus;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> category;
  final Value<String?> subcategory;
  final Value<String?> material;
  final Value<String?> variantType;
  final Value<String?> dimensionSpec;
  final Value<double> costPrice;
  final Value<double> sellingPrice;
  final Value<double> technicianPrice;
  final Value<double> minSellingPrice;
  final Value<String?> notes;
  final Value<int> rowid;
  const LocalPricingRulesCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.category = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.material = const Value.absent(),
    this.variantType = const Value.absent(),
    this.dimensionSpec = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.sellingPrice = const Value.absent(),
    this.technicianPrice = const Value.absent(),
    this.minSellingPrice = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPricingRulesCompanion.insert({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String category,
    this.subcategory = const Value.absent(),
    this.material = const Value.absent(),
    this.variantType = const Value.absent(),
    this.dimensionSpec = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.sellingPrice = const Value.absent(),
    this.technicianPrice = const Value.absent(),
    this.minSellingPrice = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : category = Value(category);
  static Insertable<LocalPricingRule> custom({
    Expression<String>? id,
    Expression<String>? syncStatus,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? category,
    Expression<String>? subcategory,
    Expression<String>? material,
    Expression<String>? variantType,
    Expression<String>? dimensionSpec,
    Expression<double>? costPrice,
    Expression<double>? sellingPrice,
    Expression<double>? technicianPrice,
    Expression<double>? minSellingPrice,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (category != null) 'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (material != null) 'material': material,
      if (variantType != null) 'variant_type': variantType,
      if (dimensionSpec != null) 'dimension_spec': dimensionSpec,
      if (costPrice != null) 'cost_price': costPrice,
      if (sellingPrice != null) 'selling_price': sellingPrice,
      if (technicianPrice != null) 'technician_price': technicianPrice,
      if (minSellingPrice != null) 'min_selling_price': minSellingPrice,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPricingRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? syncStatus,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? category,
    Value<String?>? subcategory,
    Value<String?>? material,
    Value<String?>? variantType,
    Value<String?>? dimensionSpec,
    Value<double>? costPrice,
    Value<double>? sellingPrice,
    Value<double>? technicianPrice,
    Value<double>? minSellingPrice,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return LocalPricingRulesCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      material: material ?? this.material,
      variantType: variantType ?? this.variantType,
      dimensionSpec: dimensionSpec ?? this.dimensionSpec,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      technicianPrice: technicianPrice ?? this.technicianPrice,
      minSellingPrice: minSellingPrice ?? this.minSellingPrice,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (material.present) {
      map['material'] = Variable<String>(material.value);
    }
    if (variantType.present) {
      map['variant_type'] = Variable<String>(variantType.value);
    }
    if (dimensionSpec.present) {
      map['dimension_spec'] = Variable<String>(dimensionSpec.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    if (sellingPrice.present) {
      map['selling_price'] = Variable<double>(sellingPrice.value);
    }
    if (technicianPrice.present) {
      map['technician_price'] = Variable<double>(technicianPrice.value);
    }
    if (minSellingPrice.present) {
      map['min_selling_price'] = Variable<double>(minSellingPrice.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPricingRulesCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('material: $material, ')
          ..write('variantType: $variantType, ')
          ..write('dimensionSpec: $dimensionSpec, ')
          ..write('costPrice: $costPrice, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('technicianPrice: $technicianPrice, ')
          ..write('minSellingPrice: $minSellingPrice, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalProjectsTable localProjects = $LocalProjectsTable(this);
  late final $LocalMeasurementSessionsTable localMeasurementSessions =
      $LocalMeasurementSessionsTable(this);
  late final $LocalRoomsTable localRooms = $LocalRoomsTable(this);
  late final $LocalWallsTable localWalls = $LocalWallsTable(this);
  late final $LocalWallOpeningsTable localWallOpenings =
      $LocalWallOpeningsTable(this);
  late final $LocalProductsTable localProducts = $LocalProductsTable(this);
  late final $LocalProductVariantsTable localProductVariants =
      $LocalProductVariantsTable(this);
  late final $LocalSupplierPricingsTable localSupplierPricings =
      $LocalSupplierPricingsTable(this);
  late final $LocalInventoryItemsTable localInventoryItems =
      $LocalInventoryItemsTable(this);
  late final $LocalInventoryMovementsTable localInventoryMovements =
      $LocalInventoryMovementsTable(this);
  late final $LocalQuotesTable localQuotes = $LocalQuotesTable(this);
  late final $LocalQuoteItemsTable localQuoteItems = $LocalQuoteItemsTable(
    this,
  );
  late final $LocalInvoicesTable localInvoices = $LocalInvoicesTable(this);
  late final $LocalInvoiceItemsTable localInvoiceItems =
      $LocalInvoiceItemsTable(this);
  late final $LocalCustomersTable localCustomers = $LocalCustomersTable(this);
  late final $LocalProductPresetsTable localProductPresets =
      $LocalProductPresetsTable(this);
  late final $LocalProductAssembliesTable localProductAssemblies =
      $LocalProductAssembliesTable(this);
  late final $LocalProfilesTable localProfiles = $LocalProfilesTable(this);
  late final $LocalPaymentsTable localPayments = $LocalPaymentsTable(this);
  late final $LocalSystemLogsTable localSystemLogs = $LocalSystemLogsTable(
    this,
  );
  late final $LocalPricingRulesTable localPricingRules =
      $LocalPricingRulesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localProjects,
    localMeasurementSessions,
    localRooms,
    localWalls,
    localWallOpenings,
    localProducts,
    localProductVariants,
    localSupplierPricings,
    localInventoryItems,
    localInventoryMovements,
    localQuotes,
    localQuoteItems,
    localInvoices,
    localInvoiceItems,
    localCustomers,
    localProductPresets,
    localProductAssemblies,
    localProfiles,
    localPayments,
    localSystemLogs,
    localPricingRules,
  ];
}

typedef $$LocalProjectsTableCreateCompanionBuilder =
    LocalProjectsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String title,
      Value<String?> description,
      Value<String?> customerId,
      Value<String> status,
      Value<double> netValue,
      Value<double> taxPercent,
      Value<double> totalValue,
      Value<String?> notes,
      Value<String?> address,
      Value<int> rowid,
    });
typedef $$LocalProjectsTableUpdateCompanionBuilder =
    LocalProjectsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> title,
      Value<String?> description,
      Value<String?> customerId,
      Value<String> status,
      Value<double> netValue,
      Value<double> taxPercent,
      Value<double> totalValue,
      Value<String?> notes,
      Value<String?> address,
      Value<int> rowid,
    });

class $$LocalProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProjectsTable> {
  $$LocalProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get netValue => $composableBuilder(
    column: $table.netValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxPercent => $composableBuilder(
    column: $table.taxPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalValue => $composableBuilder(
    column: $table.totalValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProjectsTable> {
  $$LocalProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get netValue => $composableBuilder(
    column: $table.netValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxPercent => $composableBuilder(
    column: $table.taxPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalValue => $composableBuilder(
    column: $table.totalValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProjectsTable> {
  $$LocalProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get netValue =>
      $composableBuilder(column: $table.netValue, builder: (column) => column);

  GeneratedColumn<double> get taxPercent => $composableBuilder(
    column: $table.taxPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalValue => $composableBuilder(
    column: $table.totalValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);
}

class $$LocalProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalProjectsTable,
          LocalProject,
          $$LocalProjectsTableFilterComposer,
          $$LocalProjectsTableOrderingComposer,
          $$LocalProjectsTableAnnotationComposer,
          $$LocalProjectsTableCreateCompanionBuilder,
          $$LocalProjectsTableUpdateCompanionBuilder,
          (
            LocalProject,
            BaseReferences<_$AppDatabase, $LocalProjectsTable, LocalProject>,
          ),
          LocalProject,
          PrefetchHooks Function()
        > {
  $$LocalProjectsTableTableManager(_$AppDatabase db, $LocalProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> netValue = const Value.absent(),
                Value<double> taxPercent = const Value.absent(),
                Value<double> totalValue = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProjectsCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                title: title,
                description: description,
                customerId: customerId,
                status: status,
                netValue: netValue,
                taxPercent: taxPercent,
                totalValue: totalValue,
                notes: notes,
                address: address,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> netValue = const Value.absent(),
                Value<double> taxPercent = const Value.absent(),
                Value<double> totalValue = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProjectsCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                title: title,
                description: description,
                customerId: customerId,
                status: status,
                netValue: netValue,
                taxPercent: taxPercent,
                totalValue: totalValue,
                notes: notes,
                address: address,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalProjectsTable,
      LocalProject,
      $$LocalProjectsTableFilterComposer,
      $$LocalProjectsTableOrderingComposer,
      $$LocalProjectsTableAnnotationComposer,
      $$LocalProjectsTableCreateCompanionBuilder,
      $$LocalProjectsTableUpdateCompanionBuilder,
      (
        LocalProject,
        BaseReferences<_$AppDatabase, $LocalProjectsTable, LocalProject>,
      ),
      LocalProject,
      PrefetchHooks Function()
    >;
typedef $$LocalMeasurementSessionsTableCreateCompanionBuilder =
    LocalMeasurementSessionsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String projectId,
      Value<String?> technicianId,
      Value<String> status,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$LocalMeasurementSessionsTableUpdateCompanionBuilder =
    LocalMeasurementSessionsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> projectId,
      Value<String?> technicianId,
      Value<String> status,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$LocalMeasurementSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMeasurementSessionsTable> {
  $$LocalMeasurementSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get technicianId => $composableBuilder(
    column: $table.technicianId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMeasurementSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMeasurementSessionsTable> {
  $$LocalMeasurementSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get technicianId => $composableBuilder(
    column: $table.technicianId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMeasurementSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMeasurementSessionsTable> {
  $$LocalMeasurementSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get technicianId => $composableBuilder(
    column: $table.technicianId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$LocalMeasurementSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMeasurementSessionsTable,
          LocalMeasurementSession,
          $$LocalMeasurementSessionsTableFilterComposer,
          $$LocalMeasurementSessionsTableOrderingComposer,
          $$LocalMeasurementSessionsTableAnnotationComposer,
          $$LocalMeasurementSessionsTableCreateCompanionBuilder,
          $$LocalMeasurementSessionsTableUpdateCompanionBuilder,
          (
            LocalMeasurementSession,
            BaseReferences<
              _$AppDatabase,
              $LocalMeasurementSessionsTable,
              LocalMeasurementSession
            >,
          ),
          LocalMeasurementSession,
          PrefetchHooks Function()
        > {
  $$LocalMeasurementSessionsTableTableManager(
    _$AppDatabase db,
    $LocalMeasurementSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMeasurementSessionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalMeasurementSessionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalMeasurementSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String?> technicianId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMeasurementSessionsCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                projectId: projectId,
                technicianId: technicianId,
                status: status,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String projectId,
                Value<String?> technicianId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMeasurementSessionsCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                projectId: projectId,
                technicianId: technicianId,
                status: status,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMeasurementSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMeasurementSessionsTable,
      LocalMeasurementSession,
      $$LocalMeasurementSessionsTableFilterComposer,
      $$LocalMeasurementSessionsTableOrderingComposer,
      $$LocalMeasurementSessionsTableAnnotationComposer,
      $$LocalMeasurementSessionsTableCreateCompanionBuilder,
      $$LocalMeasurementSessionsTableUpdateCompanionBuilder,
      (
        LocalMeasurementSession,
        BaseReferences<
          _$AppDatabase,
          $LocalMeasurementSessionsTable,
          LocalMeasurementSession
        >,
      ),
      LocalMeasurementSession,
      PrefetchHooks Function()
    >;
typedef $$LocalRoomsTableCreateCompanionBuilder =
    LocalRoomsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String sessionId,
      required String name,
      Value<String?> type,
      Value<double> length,
      Value<double> width,
      Value<double> height,
      Value<double> floorArea,
      Value<double> perimeter,
      Value<int> rowid,
    });
typedef $$LocalRoomsTableUpdateCompanionBuilder =
    LocalRoomsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> sessionId,
      Value<String> name,
      Value<String?> type,
      Value<double> length,
      Value<double> width,
      Value<double> height,
      Value<double> floorArea,
      Value<double> perimeter,
      Value<int> rowid,
    });

class $$LocalRoomsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalRoomsTable> {
  $$LocalRoomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get length => $composableBuilder(
    column: $table.length,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get floorArea => $composableBuilder(
    column: $table.floorArea,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get perimeter => $composableBuilder(
    column: $table.perimeter,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalRoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalRoomsTable> {
  $$LocalRoomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get length => $composableBuilder(
    column: $table.length,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get floorArea => $composableBuilder(
    column: $table.floorArea,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get perimeter => $composableBuilder(
    column: $table.perimeter,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalRoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalRoomsTable> {
  $$LocalRoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get length =>
      $composableBuilder(column: $table.length, builder: (column) => column);

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<double> get floorArea =>
      $composableBuilder(column: $table.floorArea, builder: (column) => column);

  GeneratedColumn<double> get perimeter =>
      $composableBuilder(column: $table.perimeter, builder: (column) => column);
}

class $$LocalRoomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalRoomsTable,
          LocalRoom,
          $$LocalRoomsTableFilterComposer,
          $$LocalRoomsTableOrderingComposer,
          $$LocalRoomsTableAnnotationComposer,
          $$LocalRoomsTableCreateCompanionBuilder,
          $$LocalRoomsTableUpdateCompanionBuilder,
          (
            LocalRoom,
            BaseReferences<_$AppDatabase, $LocalRoomsTable, LocalRoom>,
          ),
          LocalRoom,
          PrefetchHooks Function()
        > {
  $$LocalRoomsTableTableManager(_$AppDatabase db, $LocalRoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalRoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<double> length = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<double> floorArea = const Value.absent(),
                Value<double> perimeter = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRoomsCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sessionId: sessionId,
                name: name,
                type: type,
                length: length,
                width: width,
                height: height,
                floorArea: floorArea,
                perimeter: perimeter,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String sessionId,
                required String name,
                Value<String?> type = const Value.absent(),
                Value<double> length = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<double> floorArea = const Value.absent(),
                Value<double> perimeter = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRoomsCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sessionId: sessionId,
                name: name,
                type: type,
                length: length,
                width: width,
                height: height,
                floorArea: floorArea,
                perimeter: perimeter,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalRoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalRoomsTable,
      LocalRoom,
      $$LocalRoomsTableFilterComposer,
      $$LocalRoomsTableOrderingComposer,
      $$LocalRoomsTableAnnotationComposer,
      $$LocalRoomsTableCreateCompanionBuilder,
      $$LocalRoomsTableUpdateCompanionBuilder,
      (LocalRoom, BaseReferences<_$AppDatabase, $LocalRoomsTable, LocalRoom>),
      LocalRoom,
      PrefetchHooks Function()
    >;
typedef $$LocalWallsTableCreateCompanionBuilder =
    LocalWallsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String roomId,
      required String name,
      Value<double> length,
      Value<double> height,
      Value<double> grossArea,
      Value<double> netArea,
      Value<String?> materialType,
      Value<int> rowid,
    });
typedef $$LocalWallsTableUpdateCompanionBuilder =
    LocalWallsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> roomId,
      Value<String> name,
      Value<double> length,
      Value<double> height,
      Value<double> grossArea,
      Value<double> netArea,
      Value<String?> materialType,
      Value<int> rowid,
    });

class $$LocalWallsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalWallsTable> {
  $$LocalWallsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get length => $composableBuilder(
    column: $table.length,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grossArea => $composableBuilder(
    column: $table.grossArea,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get netArea => $composableBuilder(
    column: $table.netArea,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get materialType => $composableBuilder(
    column: $table.materialType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalWallsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalWallsTable> {
  $$LocalWallsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get length => $composableBuilder(
    column: $table.length,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grossArea => $composableBuilder(
    column: $table.grossArea,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get netArea => $composableBuilder(
    column: $table.netArea,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get materialType => $composableBuilder(
    column: $table.materialType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalWallsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalWallsTable> {
  $$LocalWallsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get length =>
      $composableBuilder(column: $table.length, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<double> get grossArea =>
      $composableBuilder(column: $table.grossArea, builder: (column) => column);

  GeneratedColumn<double> get netArea =>
      $composableBuilder(column: $table.netArea, builder: (column) => column);

  GeneratedColumn<String> get materialType => $composableBuilder(
    column: $table.materialType,
    builder: (column) => column,
  );
}

class $$LocalWallsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalWallsTable,
          LocalWall,
          $$LocalWallsTableFilterComposer,
          $$LocalWallsTableOrderingComposer,
          $$LocalWallsTableAnnotationComposer,
          $$LocalWallsTableCreateCompanionBuilder,
          $$LocalWallsTableUpdateCompanionBuilder,
          (
            LocalWall,
            BaseReferences<_$AppDatabase, $LocalWallsTable, LocalWall>,
          ),
          LocalWall,
          PrefetchHooks Function()
        > {
  $$LocalWallsTableTableManager(_$AppDatabase db, $LocalWallsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalWallsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalWallsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalWallsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> roomId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> length = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<double> grossArea = const Value.absent(),
                Value<double> netArea = const Value.absent(),
                Value<String?> materialType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWallsCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                roomId: roomId,
                name: name,
                length: length,
                height: height,
                grossArea: grossArea,
                netArea: netArea,
                materialType: materialType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String roomId,
                required String name,
                Value<double> length = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<double> grossArea = const Value.absent(),
                Value<double> netArea = const Value.absent(),
                Value<String?> materialType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWallsCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                roomId: roomId,
                name: name,
                length: length,
                height: height,
                grossArea: grossArea,
                netArea: netArea,
                materialType: materialType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalWallsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalWallsTable,
      LocalWall,
      $$LocalWallsTableFilterComposer,
      $$LocalWallsTableOrderingComposer,
      $$LocalWallsTableAnnotationComposer,
      $$LocalWallsTableCreateCompanionBuilder,
      $$LocalWallsTableUpdateCompanionBuilder,
      (LocalWall, BaseReferences<_$AppDatabase, $LocalWallsTable, LocalWall>),
      LocalWall,
      PrefetchHooks Function()
    >;
typedef $$LocalWallOpeningsTableCreateCompanionBuilder =
    LocalWallOpeningsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String wallId,
      required String type,
      Value<String?> name,
      Value<double> width,
      Value<double> height,
      Value<double> area,
      Value<bool> deductFromWall,
      Value<int> rowid,
    });
typedef $$LocalWallOpeningsTableUpdateCompanionBuilder =
    LocalWallOpeningsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> wallId,
      Value<String> type,
      Value<String?> name,
      Value<double> width,
      Value<double> height,
      Value<double> area,
      Value<bool> deductFromWall,
      Value<int> rowid,
    });

class $$LocalWallOpeningsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalWallOpeningsTable> {
  $$LocalWallOpeningsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wallId => $composableBuilder(
    column: $table.wallId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deductFromWall => $composableBuilder(
    column: $table.deductFromWall,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalWallOpeningsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalWallOpeningsTable> {
  $$LocalWallOpeningsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wallId => $composableBuilder(
    column: $table.wallId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deductFromWall => $composableBuilder(
    column: $table.deductFromWall,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalWallOpeningsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalWallOpeningsTable> {
  $$LocalWallOpeningsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get wallId =>
      $composableBuilder(column: $table.wallId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<double> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<bool> get deductFromWall => $composableBuilder(
    column: $table.deductFromWall,
    builder: (column) => column,
  );
}

class $$LocalWallOpeningsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalWallOpeningsTable,
          LocalWallOpening,
          $$LocalWallOpeningsTableFilterComposer,
          $$LocalWallOpeningsTableOrderingComposer,
          $$LocalWallOpeningsTableAnnotationComposer,
          $$LocalWallOpeningsTableCreateCompanionBuilder,
          $$LocalWallOpeningsTableUpdateCompanionBuilder,
          (
            LocalWallOpening,
            BaseReferences<
              _$AppDatabase,
              $LocalWallOpeningsTable,
              LocalWallOpening
            >,
          ),
          LocalWallOpening,
          PrefetchHooks Function()
        > {
  $$LocalWallOpeningsTableTableManager(
    _$AppDatabase db,
    $LocalWallOpeningsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalWallOpeningsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalWallOpeningsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalWallOpeningsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> wallId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<double> area = const Value.absent(),
                Value<bool> deductFromWall = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWallOpeningsCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                wallId: wallId,
                type: type,
                name: name,
                width: width,
                height: height,
                area: area,
                deductFromWall: deductFromWall,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String wallId,
                required String type,
                Value<String?> name = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<double> area = const Value.absent(),
                Value<bool> deductFromWall = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWallOpeningsCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                wallId: wallId,
                type: type,
                name: name,
                width: width,
                height: height,
                area: area,
                deductFromWall: deductFromWall,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalWallOpeningsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalWallOpeningsTable,
      LocalWallOpening,
      $$LocalWallOpeningsTableFilterComposer,
      $$LocalWallOpeningsTableOrderingComposer,
      $$LocalWallOpeningsTableAnnotationComposer,
      $$LocalWallOpeningsTableCreateCompanionBuilder,
      $$LocalWallOpeningsTableUpdateCompanionBuilder,
      (
        LocalWallOpening,
        BaseReferences<
          _$AppDatabase,
          $LocalWallOpeningsTable,
          LocalWallOpening
        >,
      ),
      LocalWallOpening,
      PrefetchHooks Function()
    >;
typedef $$LocalProductsTableCreateCompanionBuilder =
    LocalProductsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String name,
      Value<String?> code,
      required String category,
      Value<String?> subcategory,
      Value<String?> unitType,
      Value<String?> imageUrl,
      Value<String?> notes,
      Value<bool> isActive,
      Value<String?> brand,
      Value<String?> material,
      Value<String?> moistureResistance,
      Value<String?> installationMethod,
      Value<String?> defaultSupplierId,
      Value<int> rowid,
    });
typedef $$LocalProductsTableUpdateCompanionBuilder =
    LocalProductsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> name,
      Value<String?> code,
      Value<String> category,
      Value<String?> subcategory,
      Value<String?> unitType,
      Value<String?> imageUrl,
      Value<String?> notes,
      Value<bool> isActive,
      Value<String?> brand,
      Value<String?> material,
      Value<String?> moistureResistance,
      Value<String?> installationMethod,
      Value<String?> defaultSupplierId,
      Value<int> rowid,
    });

class $$LocalProductsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProductsTable> {
  $$LocalProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moistureResistance => $composableBuilder(
    column: $table.moistureResistance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get installationMethod => $composableBuilder(
    column: $table.installationMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultSupplierId => $composableBuilder(
    column: $table.defaultSupplierId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProductsTable> {
  $$LocalProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moistureResistance => $composableBuilder(
    column: $table.moistureResistance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get installationMethod => $composableBuilder(
    column: $table.installationMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultSupplierId => $composableBuilder(
    column: $table.defaultSupplierId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProductsTable> {
  $$LocalProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitType =>
      $composableBuilder(column: $table.unitType, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get material =>
      $composableBuilder(column: $table.material, builder: (column) => column);

  GeneratedColumn<String> get moistureResistance => $composableBuilder(
    column: $table.moistureResistance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get installationMethod => $composableBuilder(
    column: $table.installationMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultSupplierId => $composableBuilder(
    column: $table.defaultSupplierId,
    builder: (column) => column,
  );
}

class $$LocalProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalProductsTable,
          LocalProduct,
          $$LocalProductsTableFilterComposer,
          $$LocalProductsTableOrderingComposer,
          $$LocalProductsTableAnnotationComposer,
          $$LocalProductsTableCreateCompanionBuilder,
          $$LocalProductsTableUpdateCompanionBuilder,
          (
            LocalProduct,
            BaseReferences<_$AppDatabase, $LocalProductsTable, LocalProduct>,
          ),
          LocalProduct,
          PrefetchHooks Function()
        > {
  $$LocalProductsTableTableManager(_$AppDatabase db, $LocalProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> subcategory = const Value.absent(),
                Value<String?> unitType = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> material = const Value.absent(),
                Value<String?> moistureResistance = const Value.absent(),
                Value<String?> installationMethod = const Value.absent(),
                Value<String?> defaultSupplierId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProductsCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                name: name,
                code: code,
                category: category,
                subcategory: subcategory,
                unitType: unitType,
                imageUrl: imageUrl,
                notes: notes,
                isActive: isActive,
                brand: brand,
                material: material,
                moistureResistance: moistureResistance,
                installationMethod: installationMethod,
                defaultSupplierId: defaultSupplierId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String name,
                Value<String?> code = const Value.absent(),
                required String category,
                Value<String?> subcategory = const Value.absent(),
                Value<String?> unitType = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> material = const Value.absent(),
                Value<String?> moistureResistance = const Value.absent(),
                Value<String?> installationMethod = const Value.absent(),
                Value<String?> defaultSupplierId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProductsCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                name: name,
                code: code,
                category: category,
                subcategory: subcategory,
                unitType: unitType,
                imageUrl: imageUrl,
                notes: notes,
                isActive: isActive,
                brand: brand,
                material: material,
                moistureResistance: moistureResistance,
                installationMethod: installationMethod,
                defaultSupplierId: defaultSupplierId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalProductsTable,
      LocalProduct,
      $$LocalProductsTableFilterComposer,
      $$LocalProductsTableOrderingComposer,
      $$LocalProductsTableAnnotationComposer,
      $$LocalProductsTableCreateCompanionBuilder,
      $$LocalProductsTableUpdateCompanionBuilder,
      (
        LocalProduct,
        BaseReferences<_$AppDatabase, $LocalProductsTable, LocalProduct>,
      ),
      LocalProduct,
      PrefetchHooks Function()
    >;
typedef $$LocalProductVariantsTableCreateCompanionBuilder =
    LocalProductVariantsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String productId,
      required String variantName,
      Value<String?> color,
      Value<String?> dimensions,
      Value<double?> pieceLength,
      Value<double?> pieceWidth,
      Value<double?> thickness,
      Value<double?> effectiveCoverageWidth,
      Value<double?> defaultWastePercent,
      Value<String?> imageUrl,
      Value<double?> minSellingPrice,
      Value<double?> costPriceOverride,
      Value<double?> sellingPriceOverride,
      Value<double?> technicianPriceOverride,
      Value<int> rowid,
    });
typedef $$LocalProductVariantsTableUpdateCompanionBuilder =
    LocalProductVariantsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> productId,
      Value<String> variantName,
      Value<String?> color,
      Value<String?> dimensions,
      Value<double?> pieceLength,
      Value<double?> pieceWidth,
      Value<double?> thickness,
      Value<double?> effectiveCoverageWidth,
      Value<double?> defaultWastePercent,
      Value<String?> imageUrl,
      Value<double?> minSellingPrice,
      Value<double?> costPriceOverride,
      Value<double?> sellingPriceOverride,
      Value<double?> technicianPriceOverride,
      Value<int> rowid,
    });

class $$LocalProductVariantsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProductVariantsTable> {
  $$LocalProductVariantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variantName => $composableBuilder(
    column: $table.variantName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pieceLength => $composableBuilder(
    column: $table.pieceLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pieceWidth => $composableBuilder(
    column: $table.pieceWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get thickness => $composableBuilder(
    column: $table.thickness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get effectiveCoverageWidth => $composableBuilder(
    column: $table.effectiveCoverageWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultWastePercent => $composableBuilder(
    column: $table.defaultWastePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minSellingPrice => $composableBuilder(
    column: $table.minSellingPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPriceOverride => $composableBuilder(
    column: $table.costPriceOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sellingPriceOverride => $composableBuilder(
    column: $table.sellingPriceOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get technicianPriceOverride => $composableBuilder(
    column: $table.technicianPriceOverride,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalProductVariantsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProductVariantsTable> {
  $$LocalProductVariantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variantName => $composableBuilder(
    column: $table.variantName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pieceLength => $composableBuilder(
    column: $table.pieceLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pieceWidth => $composableBuilder(
    column: $table.pieceWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get thickness => $composableBuilder(
    column: $table.thickness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get effectiveCoverageWidth => $composableBuilder(
    column: $table.effectiveCoverageWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultWastePercent => $composableBuilder(
    column: $table.defaultWastePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minSellingPrice => $composableBuilder(
    column: $table.minSellingPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPriceOverride => $composableBuilder(
    column: $table.costPriceOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sellingPriceOverride => $composableBuilder(
    column: $table.sellingPriceOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get technicianPriceOverride => $composableBuilder(
    column: $table.technicianPriceOverride,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalProductVariantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProductVariantsTable> {
  $$LocalProductVariantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get variantName => $composableBuilder(
    column: $table.variantName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pieceLength => $composableBuilder(
    column: $table.pieceLength,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pieceWidth => $composableBuilder(
    column: $table.pieceWidth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get thickness =>
      $composableBuilder(column: $table.thickness, builder: (column) => column);

  GeneratedColumn<double> get effectiveCoverageWidth => $composableBuilder(
    column: $table.effectiveCoverageWidth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultWastePercent => $composableBuilder(
    column: $table.defaultWastePercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<double> get minSellingPrice => $composableBuilder(
    column: $table.minSellingPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costPriceOverride => $composableBuilder(
    column: $table.costPriceOverride,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sellingPriceOverride => $composableBuilder(
    column: $table.sellingPriceOverride,
    builder: (column) => column,
  );

  GeneratedColumn<double> get technicianPriceOverride => $composableBuilder(
    column: $table.technicianPriceOverride,
    builder: (column) => column,
  );
}

class $$LocalProductVariantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalProductVariantsTable,
          LocalProductVariant,
          $$LocalProductVariantsTableFilterComposer,
          $$LocalProductVariantsTableOrderingComposer,
          $$LocalProductVariantsTableAnnotationComposer,
          $$LocalProductVariantsTableCreateCompanionBuilder,
          $$LocalProductVariantsTableUpdateCompanionBuilder,
          (
            LocalProductVariant,
            BaseReferences<
              _$AppDatabase,
              $LocalProductVariantsTable,
              LocalProductVariant
            >,
          ),
          LocalProductVariant,
          PrefetchHooks Function()
        > {
  $$LocalProductVariantsTableTableManager(
    _$AppDatabase db,
    $LocalProductVariantsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProductVariantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProductVariantsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalProductVariantsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> variantName = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> dimensions = const Value.absent(),
                Value<double?> pieceLength = const Value.absent(),
                Value<double?> pieceWidth = const Value.absent(),
                Value<double?> thickness = const Value.absent(),
                Value<double?> effectiveCoverageWidth = const Value.absent(),
                Value<double?> defaultWastePercent = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<double?> minSellingPrice = const Value.absent(),
                Value<double?> costPriceOverride = const Value.absent(),
                Value<double?> sellingPriceOverride = const Value.absent(),
                Value<double?> technicianPriceOverride = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProductVariantsCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                productId: productId,
                variantName: variantName,
                color: color,
                dimensions: dimensions,
                pieceLength: pieceLength,
                pieceWidth: pieceWidth,
                thickness: thickness,
                effectiveCoverageWidth: effectiveCoverageWidth,
                defaultWastePercent: defaultWastePercent,
                imageUrl: imageUrl,
                minSellingPrice: minSellingPrice,
                costPriceOverride: costPriceOverride,
                sellingPriceOverride: sellingPriceOverride,
                technicianPriceOverride: technicianPriceOverride,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String productId,
                required String variantName,
                Value<String?> color = const Value.absent(),
                Value<String?> dimensions = const Value.absent(),
                Value<double?> pieceLength = const Value.absent(),
                Value<double?> pieceWidth = const Value.absent(),
                Value<double?> thickness = const Value.absent(),
                Value<double?> effectiveCoverageWidth = const Value.absent(),
                Value<double?> defaultWastePercent = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<double?> minSellingPrice = const Value.absent(),
                Value<double?> costPriceOverride = const Value.absent(),
                Value<double?> sellingPriceOverride = const Value.absent(),
                Value<double?> technicianPriceOverride = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProductVariantsCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                productId: productId,
                variantName: variantName,
                color: color,
                dimensions: dimensions,
                pieceLength: pieceLength,
                pieceWidth: pieceWidth,
                thickness: thickness,
                effectiveCoverageWidth: effectiveCoverageWidth,
                defaultWastePercent: defaultWastePercent,
                imageUrl: imageUrl,
                minSellingPrice: minSellingPrice,
                costPriceOverride: costPriceOverride,
                sellingPriceOverride: sellingPriceOverride,
                technicianPriceOverride: technicianPriceOverride,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalProductVariantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalProductVariantsTable,
      LocalProductVariant,
      $$LocalProductVariantsTableFilterComposer,
      $$LocalProductVariantsTableOrderingComposer,
      $$LocalProductVariantsTableAnnotationComposer,
      $$LocalProductVariantsTableCreateCompanionBuilder,
      $$LocalProductVariantsTableUpdateCompanionBuilder,
      (
        LocalProductVariant,
        BaseReferences<
          _$AppDatabase,
          $LocalProductVariantsTable,
          LocalProductVariant
        >,
      ),
      LocalProductVariant,
      PrefetchHooks Function()
    >;
typedef $$LocalSupplierPricingsTableCreateCompanionBuilder =
    LocalSupplierPricingsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String productVariantId,
      Value<String?> supplierId,
      Value<String?> supplierCode,
      Value<double> listPrice,
      Value<double> netPrice,
      Value<double> discountValue,
      Value<bool> isPreferred,
      Value<int> rowid,
    });
typedef $$LocalSupplierPricingsTableUpdateCompanionBuilder =
    LocalSupplierPricingsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> productVariantId,
      Value<String?> supplierId,
      Value<String?> supplierCode,
      Value<double> listPrice,
      Value<double> netPrice,
      Value<double> discountValue,
      Value<bool> isPreferred,
      Value<int> rowid,
    });

class $$LocalSupplierPricingsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSupplierPricingsTable> {
  $$LocalSupplierPricingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierCode => $composableBuilder(
    column: $table.supplierCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get listPrice => $composableBuilder(
    column: $table.listPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get netPrice => $composableBuilder(
    column: $table.netPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPreferred => $composableBuilder(
    column: $table.isPreferred,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSupplierPricingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSupplierPricingsTable> {
  $$LocalSupplierPricingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierCode => $composableBuilder(
    column: $table.supplierCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get listPrice => $composableBuilder(
    column: $table.listPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get netPrice => $composableBuilder(
    column: $table.netPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPreferred => $composableBuilder(
    column: $table.isPreferred,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSupplierPricingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSupplierPricingsTable> {
  $$LocalSupplierPricingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplierCode => $composableBuilder(
    column: $table.supplierCode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get listPrice =>
      $composableBuilder(column: $table.listPrice, builder: (column) => column);

  GeneratedColumn<double> get netPrice =>
      $composableBuilder(column: $table.netPrice, builder: (column) => column);

  GeneratedColumn<double> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPreferred => $composableBuilder(
    column: $table.isPreferred,
    builder: (column) => column,
  );
}

class $$LocalSupplierPricingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSupplierPricingsTable,
          LocalSupplierPricing,
          $$LocalSupplierPricingsTableFilterComposer,
          $$LocalSupplierPricingsTableOrderingComposer,
          $$LocalSupplierPricingsTableAnnotationComposer,
          $$LocalSupplierPricingsTableCreateCompanionBuilder,
          $$LocalSupplierPricingsTableUpdateCompanionBuilder,
          (
            LocalSupplierPricing,
            BaseReferences<
              _$AppDatabase,
              $LocalSupplierPricingsTable,
              LocalSupplierPricing
            >,
          ),
          LocalSupplierPricing,
          PrefetchHooks Function()
        > {
  $$LocalSupplierPricingsTableTableManager(
    _$AppDatabase db,
    $LocalSupplierPricingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSupplierPricingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalSupplierPricingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalSupplierPricingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> productVariantId = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                Value<String?> supplierCode = const Value.absent(),
                Value<double> listPrice = const Value.absent(),
                Value<double> netPrice = const Value.absent(),
                Value<double> discountValue = const Value.absent(),
                Value<bool> isPreferred = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSupplierPricingsCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                productVariantId: productVariantId,
                supplierId: supplierId,
                supplierCode: supplierCode,
                listPrice: listPrice,
                netPrice: netPrice,
                discountValue: discountValue,
                isPreferred: isPreferred,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String productVariantId,
                Value<String?> supplierId = const Value.absent(),
                Value<String?> supplierCode = const Value.absent(),
                Value<double> listPrice = const Value.absent(),
                Value<double> netPrice = const Value.absent(),
                Value<double> discountValue = const Value.absent(),
                Value<bool> isPreferred = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSupplierPricingsCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                productVariantId: productVariantId,
                supplierId: supplierId,
                supplierCode: supplierCode,
                listPrice: listPrice,
                netPrice: netPrice,
                discountValue: discountValue,
                isPreferred: isPreferred,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSupplierPricingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSupplierPricingsTable,
      LocalSupplierPricing,
      $$LocalSupplierPricingsTableFilterComposer,
      $$LocalSupplierPricingsTableOrderingComposer,
      $$LocalSupplierPricingsTableAnnotationComposer,
      $$LocalSupplierPricingsTableCreateCompanionBuilder,
      $$LocalSupplierPricingsTableUpdateCompanionBuilder,
      (
        LocalSupplierPricing,
        BaseReferences<
          _$AppDatabase,
          $LocalSupplierPricingsTable,
          LocalSupplierPricing
        >,
      ),
      LocalSupplierPricing,
      PrefetchHooks Function()
    >;
typedef $$LocalInventoryItemsTableCreateCompanionBuilder =
    LocalInventoryItemsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String productVariantId,
      Value<double> availableQty,
      Value<double> reservedQty,
      Value<double> damagedQty,
      Value<double> reorderPoint,
      Value<int> rowid,
    });
typedef $$LocalInventoryItemsTableUpdateCompanionBuilder =
    LocalInventoryItemsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> productVariantId,
      Value<double> availableQty,
      Value<double> reservedQty,
      Value<double> damagedQty,
      Value<double> reorderPoint,
      Value<int> rowid,
    });

class $$LocalInventoryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalInventoryItemsTable> {
  $$LocalInventoryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get availableQty => $composableBuilder(
    column: $table.availableQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get reservedQty => $composableBuilder(
    column: $table.reservedQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get damagedQty => $composableBuilder(
    column: $table.damagedQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get reorderPoint => $composableBuilder(
    column: $table.reorderPoint,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalInventoryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalInventoryItemsTable> {
  $$LocalInventoryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get availableQty => $composableBuilder(
    column: $table.availableQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get reservedQty => $composableBuilder(
    column: $table.reservedQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get damagedQty => $composableBuilder(
    column: $table.damagedQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get reorderPoint => $composableBuilder(
    column: $table.reorderPoint,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalInventoryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalInventoryItemsTable> {
  $$LocalInventoryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get availableQty => $composableBuilder(
    column: $table.availableQty,
    builder: (column) => column,
  );

  GeneratedColumn<double> get reservedQty => $composableBuilder(
    column: $table.reservedQty,
    builder: (column) => column,
  );

  GeneratedColumn<double> get damagedQty => $composableBuilder(
    column: $table.damagedQty,
    builder: (column) => column,
  );

  GeneratedColumn<double> get reorderPoint => $composableBuilder(
    column: $table.reorderPoint,
    builder: (column) => column,
  );
}

class $$LocalInventoryItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalInventoryItemsTable,
          LocalInventoryItem,
          $$LocalInventoryItemsTableFilterComposer,
          $$LocalInventoryItemsTableOrderingComposer,
          $$LocalInventoryItemsTableAnnotationComposer,
          $$LocalInventoryItemsTableCreateCompanionBuilder,
          $$LocalInventoryItemsTableUpdateCompanionBuilder,
          (
            LocalInventoryItem,
            BaseReferences<
              _$AppDatabase,
              $LocalInventoryItemsTable,
              LocalInventoryItem
            >,
          ),
          LocalInventoryItem,
          PrefetchHooks Function()
        > {
  $$LocalInventoryItemsTableTableManager(
    _$AppDatabase db,
    $LocalInventoryItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalInventoryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalInventoryItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalInventoryItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> productVariantId = const Value.absent(),
                Value<double> availableQty = const Value.absent(),
                Value<double> reservedQty = const Value.absent(),
                Value<double> damagedQty = const Value.absent(),
                Value<double> reorderPoint = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInventoryItemsCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                productVariantId: productVariantId,
                availableQty: availableQty,
                reservedQty: reservedQty,
                damagedQty: damagedQty,
                reorderPoint: reorderPoint,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String productVariantId,
                Value<double> availableQty = const Value.absent(),
                Value<double> reservedQty = const Value.absent(),
                Value<double> damagedQty = const Value.absent(),
                Value<double> reorderPoint = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInventoryItemsCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                productVariantId: productVariantId,
                availableQty: availableQty,
                reservedQty: reservedQty,
                damagedQty: damagedQty,
                reorderPoint: reorderPoint,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalInventoryItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalInventoryItemsTable,
      LocalInventoryItem,
      $$LocalInventoryItemsTableFilterComposer,
      $$LocalInventoryItemsTableOrderingComposer,
      $$LocalInventoryItemsTableAnnotationComposer,
      $$LocalInventoryItemsTableCreateCompanionBuilder,
      $$LocalInventoryItemsTableUpdateCompanionBuilder,
      (
        LocalInventoryItem,
        BaseReferences<
          _$AppDatabase,
          $LocalInventoryItemsTable,
          LocalInventoryItem
        >,
      ),
      LocalInventoryItem,
      PrefetchHooks Function()
    >;
typedef $$LocalInventoryMovementsTableCreateCompanionBuilder =
    LocalInventoryMovementsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String inventoryItemId,
      required String movementType,
      Value<double> quantity,
      Value<String?> referenceId,
      Value<String?> notes,
      Value<String?> createdBy,
      Value<int> rowid,
    });
typedef $$LocalInventoryMovementsTableUpdateCompanionBuilder =
    LocalInventoryMovementsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> inventoryItemId,
      Value<String> movementType,
      Value<double> quantity,
      Value<String?> referenceId,
      Value<String?> notes,
      Value<String?> createdBy,
      Value<int> rowid,
    });

class $$LocalInventoryMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalInventoryMovementsTable> {
  $$LocalInventoryMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inventoryItemId => $composableBuilder(
    column: $table.inventoryItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalInventoryMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalInventoryMovementsTable> {
  $$LocalInventoryMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inventoryItemId => $composableBuilder(
    column: $table.inventoryItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalInventoryMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalInventoryMovementsTable> {
  $$LocalInventoryMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get inventoryItemId => $composableBuilder(
    column: $table.inventoryItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);
}

class $$LocalInventoryMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalInventoryMovementsTable,
          LocalInventoryMovement,
          $$LocalInventoryMovementsTableFilterComposer,
          $$LocalInventoryMovementsTableOrderingComposer,
          $$LocalInventoryMovementsTableAnnotationComposer,
          $$LocalInventoryMovementsTableCreateCompanionBuilder,
          $$LocalInventoryMovementsTableUpdateCompanionBuilder,
          (
            LocalInventoryMovement,
            BaseReferences<
              _$AppDatabase,
              $LocalInventoryMovementsTable,
              LocalInventoryMovement
            >,
          ),
          LocalInventoryMovement,
          PrefetchHooks Function()
        > {
  $$LocalInventoryMovementsTableTableManager(
    _$AppDatabase db,
    $LocalInventoryMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalInventoryMovementsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalInventoryMovementsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalInventoryMovementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> inventoryItemId = const Value.absent(),
                Value<String> movementType = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInventoryMovementsCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                inventoryItemId: inventoryItemId,
                movementType: movementType,
                quantity: quantity,
                referenceId: referenceId,
                notes: notes,
                createdBy: createdBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String inventoryItemId,
                required String movementType,
                Value<double> quantity = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInventoryMovementsCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                inventoryItemId: inventoryItemId,
                movementType: movementType,
                quantity: quantity,
                referenceId: referenceId,
                notes: notes,
                createdBy: createdBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalInventoryMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalInventoryMovementsTable,
      LocalInventoryMovement,
      $$LocalInventoryMovementsTableFilterComposer,
      $$LocalInventoryMovementsTableOrderingComposer,
      $$LocalInventoryMovementsTableAnnotationComposer,
      $$LocalInventoryMovementsTableCreateCompanionBuilder,
      $$LocalInventoryMovementsTableUpdateCompanionBuilder,
      (
        LocalInventoryMovement,
        BaseReferences<
          _$AppDatabase,
          $LocalInventoryMovementsTable,
          LocalInventoryMovement
        >,
      ),
      LocalInventoryMovement,
      PrefetchHooks Function()
    >;
typedef $$LocalQuotesTableCreateCompanionBuilder =
    LocalQuotesCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> quoteNumber,
      Value<String?> customerId,
      Value<String> status,
      Value<double> totalAmount,
      Value<double> taxAmount,
      Value<double> discountAmount,
      Value<String?> notes,
      Value<DateTime?> validUntil,
      Value<int> rowid,
    });
typedef $$LocalQuotesTableUpdateCompanionBuilder =
    LocalQuotesCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> quoteNumber,
      Value<String?> customerId,
      Value<String> status,
      Value<double> totalAmount,
      Value<double> taxAmount,
      Value<double> discountAmount,
      Value<String?> notes,
      Value<DateTime?> validUntil,
      Value<int> rowid,
    });

class $$LocalQuotesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalQuotesTable> {
  $$LocalQuotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quoteNumber => $composableBuilder(
    column: $table.quoteNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalQuotesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalQuotesTable> {
  $$LocalQuotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quoteNumber => $composableBuilder(
    column: $table.quoteNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalQuotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalQuotesTable> {
  $$LocalQuotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get quoteNumber => $composableBuilder(
    column: $table.quoteNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => column,
  );
}

class $$LocalQuotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalQuotesTable,
          LocalQuote,
          $$LocalQuotesTableFilterComposer,
          $$LocalQuotesTableOrderingComposer,
          $$LocalQuotesTableAnnotationComposer,
          $$LocalQuotesTableCreateCompanionBuilder,
          $$LocalQuotesTableUpdateCompanionBuilder,
          (
            LocalQuote,
            BaseReferences<_$AppDatabase, $LocalQuotesTable, LocalQuote>,
          ),
          LocalQuote,
          PrefetchHooks Function()
        > {
  $$LocalQuotesTableTableManager(_$AppDatabase db, $LocalQuotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalQuotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalQuotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalQuotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> quoteNumber = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<double> taxAmount = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> validUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalQuotesCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                quoteNumber: quoteNumber,
                customerId: customerId,
                status: status,
                totalAmount: totalAmount,
                taxAmount: taxAmount,
                discountAmount: discountAmount,
                notes: notes,
                validUntil: validUntil,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> quoteNumber = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<double> taxAmount = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> validUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalQuotesCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                quoteNumber: quoteNumber,
                customerId: customerId,
                status: status,
                totalAmount: totalAmount,
                taxAmount: taxAmount,
                discountAmount: discountAmount,
                notes: notes,
                validUntil: validUntil,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalQuotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalQuotesTable,
      LocalQuote,
      $$LocalQuotesTableFilterComposer,
      $$LocalQuotesTableOrderingComposer,
      $$LocalQuotesTableAnnotationComposer,
      $$LocalQuotesTableCreateCompanionBuilder,
      $$LocalQuotesTableUpdateCompanionBuilder,
      (
        LocalQuote,
        BaseReferences<_$AppDatabase, $LocalQuotesTable, LocalQuote>,
      ),
      LocalQuote,
      PrefetchHooks Function()
    >;
typedef $$LocalQuoteItemsTableCreateCompanionBuilder =
    LocalQuoteItemsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String quoteId,
      required String productVariantId,
      Value<double> quantity,
      Value<double> unitPrice,
      Value<double> totalPrice,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$LocalQuoteItemsTableUpdateCompanionBuilder =
    LocalQuoteItemsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> quoteId,
      Value<String> productVariantId,
      Value<double> quantity,
      Value<double> unitPrice,
      Value<double> totalPrice,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$LocalQuoteItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalQuoteItemsTable> {
  $$LocalQuoteItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quoteId => $composableBuilder(
    column: $table.quoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalQuoteItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalQuoteItemsTable> {
  $$LocalQuoteItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quoteId => $composableBuilder(
    column: $table.quoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalQuoteItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalQuoteItemsTable> {
  $$LocalQuoteItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get quoteId =>
      $composableBuilder(column: $table.quoteId, builder: (column) => column);

  GeneratedColumn<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$LocalQuoteItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalQuoteItemsTable,
          LocalQuoteItem,
          $$LocalQuoteItemsTableFilterComposer,
          $$LocalQuoteItemsTableOrderingComposer,
          $$LocalQuoteItemsTableAnnotationComposer,
          $$LocalQuoteItemsTableCreateCompanionBuilder,
          $$LocalQuoteItemsTableUpdateCompanionBuilder,
          (
            LocalQuoteItem,
            BaseReferences<
              _$AppDatabase,
              $LocalQuoteItemsTable,
              LocalQuoteItem
            >,
          ),
          LocalQuoteItem,
          PrefetchHooks Function()
        > {
  $$LocalQuoteItemsTableTableManager(
    _$AppDatabase db,
    $LocalQuoteItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalQuoteItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalQuoteItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalQuoteItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> quoteId = const Value.absent(),
                Value<String> productVariantId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> totalPrice = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalQuoteItemsCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                quoteId: quoteId,
                productVariantId: productVariantId,
                quantity: quantity,
                unitPrice: unitPrice,
                totalPrice: totalPrice,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String quoteId,
                required String productVariantId,
                Value<double> quantity = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> totalPrice = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalQuoteItemsCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                quoteId: quoteId,
                productVariantId: productVariantId,
                quantity: quantity,
                unitPrice: unitPrice,
                totalPrice: totalPrice,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalQuoteItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalQuoteItemsTable,
      LocalQuoteItem,
      $$LocalQuoteItemsTableFilterComposer,
      $$LocalQuoteItemsTableOrderingComposer,
      $$LocalQuoteItemsTableAnnotationComposer,
      $$LocalQuoteItemsTableCreateCompanionBuilder,
      $$LocalQuoteItemsTableUpdateCompanionBuilder,
      (
        LocalQuoteItem,
        BaseReferences<_$AppDatabase, $LocalQuoteItemsTable, LocalQuoteItem>,
      ),
      LocalQuoteItem,
      PrefetchHooks Function()
    >;
typedef $$LocalInvoicesTableCreateCompanionBuilder =
    LocalInvoicesCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> invoiceNumber,
      Value<String?> customerId,
      Value<String> status,
      Value<String> invoiceType,
      Value<String?> originalInvoiceId,
      Value<double> totalAmount,
      Value<double> amountPaid,
      Value<double> taxAmount,
      Value<double> discountAmount,
      Value<String?> notes,
      Value<DateTime?> dueDate,
      Value<DateTime?> confirmedAt,
      Value<int> rowid,
    });
typedef $$LocalInvoicesTableUpdateCompanionBuilder =
    LocalInvoicesCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> invoiceNumber,
      Value<String?> customerId,
      Value<String> status,
      Value<String> invoiceType,
      Value<String?> originalInvoiceId,
      Value<double> totalAmount,
      Value<double> amountPaid,
      Value<double> taxAmount,
      Value<double> discountAmount,
      Value<String?> notes,
      Value<DateTime?> dueDate,
      Value<DateTime?> confirmedAt,
      Value<int> rowid,
    });

class $$LocalInvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalInvoicesTable> {
  $$LocalInvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceType => $composableBuilder(
    column: $table.invoiceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalInvoiceId => $composableBuilder(
    column: $table.originalInvoiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalInvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalInvoicesTable> {
  $$LocalInvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceType => $composableBuilder(
    column: $table.invoiceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalInvoiceId => $composableBuilder(
    column: $table.originalInvoiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalInvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalInvoicesTable> {
  $$LocalInvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get invoiceType => $composableBuilder(
    column: $table.invoiceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalInvoiceId => $composableBuilder(
    column: $table.originalInvoiceId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => column,
  );
}

class $$LocalInvoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalInvoicesTable,
          LocalInvoice,
          $$LocalInvoicesTableFilterComposer,
          $$LocalInvoicesTableOrderingComposer,
          $$LocalInvoicesTableAnnotationComposer,
          $$LocalInvoicesTableCreateCompanionBuilder,
          $$LocalInvoicesTableUpdateCompanionBuilder,
          (
            LocalInvoice,
            BaseReferences<_$AppDatabase, $LocalInvoicesTable, LocalInvoice>,
          ),
          LocalInvoice,
          PrefetchHooks Function()
        > {
  $$LocalInvoicesTableTableManager(_$AppDatabase db, $LocalInvoicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalInvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalInvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalInvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> invoiceNumber = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> invoiceType = const Value.absent(),
                Value<String?> originalInvoiceId = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<double> taxAmount = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> confirmedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInvoicesCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                invoiceNumber: invoiceNumber,
                customerId: customerId,
                status: status,
                invoiceType: invoiceType,
                originalInvoiceId: originalInvoiceId,
                totalAmount: totalAmount,
                amountPaid: amountPaid,
                taxAmount: taxAmount,
                discountAmount: discountAmount,
                notes: notes,
                dueDate: dueDate,
                confirmedAt: confirmedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> invoiceNumber = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> invoiceType = const Value.absent(),
                Value<String?> originalInvoiceId = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<double> taxAmount = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> confirmedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInvoicesCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                invoiceNumber: invoiceNumber,
                customerId: customerId,
                status: status,
                invoiceType: invoiceType,
                originalInvoiceId: originalInvoiceId,
                totalAmount: totalAmount,
                amountPaid: amountPaid,
                taxAmount: taxAmount,
                discountAmount: discountAmount,
                notes: notes,
                dueDate: dueDate,
                confirmedAt: confirmedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalInvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalInvoicesTable,
      LocalInvoice,
      $$LocalInvoicesTableFilterComposer,
      $$LocalInvoicesTableOrderingComposer,
      $$LocalInvoicesTableAnnotationComposer,
      $$LocalInvoicesTableCreateCompanionBuilder,
      $$LocalInvoicesTableUpdateCompanionBuilder,
      (
        LocalInvoice,
        BaseReferences<_$AppDatabase, $LocalInvoicesTable, LocalInvoice>,
      ),
      LocalInvoice,
      PrefetchHooks Function()
    >;
typedef $$LocalInvoiceItemsTableCreateCompanionBuilder =
    LocalInvoiceItemsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String invoiceId,
      required String productVariantId,
      Value<double> quantity,
      Value<double> unitPrice,
      Value<double> totalPrice,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$LocalInvoiceItemsTableUpdateCompanionBuilder =
    LocalInvoiceItemsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> invoiceId,
      Value<String> productVariantId,
      Value<double> quantity,
      Value<double> unitPrice,
      Value<double> totalPrice,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$LocalInvoiceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalInvoiceItemsTable> {
  $$LocalInvoiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalInvoiceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalInvoiceItemsTable> {
  $$LocalInvoiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalInvoiceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalInvoiceItemsTable> {
  $$LocalInvoiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  GeneratedColumn<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$LocalInvoiceItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalInvoiceItemsTable,
          LocalInvoiceItem,
          $$LocalInvoiceItemsTableFilterComposer,
          $$LocalInvoiceItemsTableOrderingComposer,
          $$LocalInvoiceItemsTableAnnotationComposer,
          $$LocalInvoiceItemsTableCreateCompanionBuilder,
          $$LocalInvoiceItemsTableUpdateCompanionBuilder,
          (
            LocalInvoiceItem,
            BaseReferences<
              _$AppDatabase,
              $LocalInvoiceItemsTable,
              LocalInvoiceItem
            >,
          ),
          LocalInvoiceItem,
          PrefetchHooks Function()
        > {
  $$LocalInvoiceItemsTableTableManager(
    _$AppDatabase db,
    $LocalInvoiceItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalInvoiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalInvoiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalInvoiceItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> invoiceId = const Value.absent(),
                Value<String> productVariantId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> totalPrice = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInvoiceItemsCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                invoiceId: invoiceId,
                productVariantId: productVariantId,
                quantity: quantity,
                unitPrice: unitPrice,
                totalPrice: totalPrice,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String invoiceId,
                required String productVariantId,
                Value<double> quantity = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> totalPrice = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInvoiceItemsCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                invoiceId: invoiceId,
                productVariantId: productVariantId,
                quantity: quantity,
                unitPrice: unitPrice,
                totalPrice: totalPrice,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalInvoiceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalInvoiceItemsTable,
      LocalInvoiceItem,
      $$LocalInvoiceItemsTableFilterComposer,
      $$LocalInvoiceItemsTableOrderingComposer,
      $$LocalInvoiceItemsTableAnnotationComposer,
      $$LocalInvoiceItemsTableCreateCompanionBuilder,
      $$LocalInvoiceItemsTableUpdateCompanionBuilder,
      (
        LocalInvoiceItem,
        BaseReferences<
          _$AppDatabase,
          $LocalInvoiceItemsTable,
          LocalInvoiceItem
        >,
      ),
      LocalInvoiceItem,
      PrefetchHooks Function()
    >;
typedef $$LocalCustomersTableCreateCompanionBuilder =
    LocalCustomersCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String name,
      Value<String?> phone,
      Value<String?> address,
      Value<String?> type,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$LocalCustomersTableUpdateCompanionBuilder =
    LocalCustomersCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> name,
      Value<String?> phone,
      Value<String?> address,
      Value<String?> type,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$LocalCustomersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCustomersTable> {
  $$LocalCustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCustomersTable> {
  $$LocalCustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCustomersTable> {
  $$LocalCustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$LocalCustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCustomersTable,
          LocalCustomer,
          $$LocalCustomersTableFilterComposer,
          $$LocalCustomersTableOrderingComposer,
          $$LocalCustomersTableAnnotationComposer,
          $$LocalCustomersTableCreateCompanionBuilder,
          $$LocalCustomersTableUpdateCompanionBuilder,
          (
            LocalCustomer,
            BaseReferences<_$AppDatabase, $LocalCustomersTable, LocalCustomer>,
          ),
          LocalCustomer,
          PrefetchHooks Function()
        > {
  $$LocalCustomersTableTableManager(
    _$AppDatabase db,
    $LocalCustomersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCustomersCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                name: name,
                phone: phone,
                address: address,
                type: type,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCustomersCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                name: name,
                phone: phone,
                address: address,
                type: type,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCustomersTable,
      LocalCustomer,
      $$LocalCustomersTableFilterComposer,
      $$LocalCustomersTableOrderingComposer,
      $$LocalCustomersTableAnnotationComposer,
      $$LocalCustomersTableCreateCompanionBuilder,
      $$LocalCustomersTableUpdateCompanionBuilder,
      (
        LocalCustomer,
        BaseReferences<_$AppDatabase, $LocalCustomersTable, LocalCustomer>,
      ),
      LocalCustomer,
      PrefetchHooks Function()
    >;
typedef $$LocalProductPresetsTableCreateCompanionBuilder =
    LocalProductPresetsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String productVariantId,
      required String name,
      Value<String?> presetData,
      Value<int> rowid,
    });
typedef $$LocalProductPresetsTableUpdateCompanionBuilder =
    LocalProductPresetsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> productVariantId,
      Value<String> name,
      Value<String?> presetData,
      Value<int> rowid,
    });

class $$LocalProductPresetsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProductPresetsTable> {
  $$LocalProductPresetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presetData => $composableBuilder(
    column: $table.presetData,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalProductPresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProductPresetsTable> {
  $$LocalProductPresetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presetData => $composableBuilder(
    column: $table.presetData,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalProductPresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProductPresetsTable> {
  $$LocalProductPresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get presetData => $composableBuilder(
    column: $table.presetData,
    builder: (column) => column,
  );
}

class $$LocalProductPresetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalProductPresetsTable,
          LocalProductPreset,
          $$LocalProductPresetsTableFilterComposer,
          $$LocalProductPresetsTableOrderingComposer,
          $$LocalProductPresetsTableAnnotationComposer,
          $$LocalProductPresetsTableCreateCompanionBuilder,
          $$LocalProductPresetsTableUpdateCompanionBuilder,
          (
            LocalProductPreset,
            BaseReferences<
              _$AppDatabase,
              $LocalProductPresetsTable,
              LocalProductPreset
            >,
          ),
          LocalProductPreset,
          PrefetchHooks Function()
        > {
  $$LocalProductPresetsTableTableManager(
    _$AppDatabase db,
    $LocalProductPresetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProductPresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProductPresetsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalProductPresetsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> productVariantId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> presetData = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProductPresetsCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                productVariantId: productVariantId,
                name: name,
                presetData: presetData,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String productVariantId,
                required String name,
                Value<String?> presetData = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProductPresetsCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                productVariantId: productVariantId,
                name: name,
                presetData: presetData,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalProductPresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalProductPresetsTable,
      LocalProductPreset,
      $$LocalProductPresetsTableFilterComposer,
      $$LocalProductPresetsTableOrderingComposer,
      $$LocalProductPresetsTableAnnotationComposer,
      $$LocalProductPresetsTableCreateCompanionBuilder,
      $$LocalProductPresetsTableUpdateCompanionBuilder,
      (
        LocalProductPreset,
        BaseReferences<
          _$AppDatabase,
          $LocalProductPresetsTable,
          LocalProductPreset
        >,
      ),
      LocalProductPreset,
      PrefetchHooks Function()
    >;
typedef $$LocalProductAssembliesTableCreateCompanionBuilder =
    LocalProductAssembliesCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String productVariantId,
      required String accessoryProductId,
      Value<double> quantity,
      Value<int> rowid,
    });
typedef $$LocalProductAssembliesTableUpdateCompanionBuilder =
    LocalProductAssembliesCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> productVariantId,
      Value<String> accessoryProductId,
      Value<double> quantity,
      Value<int> rowid,
    });

class $$LocalProductAssembliesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProductAssembliesTable> {
  $$LocalProductAssembliesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessoryProductId => $composableBuilder(
    column: $table.accessoryProductId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalProductAssembliesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProductAssembliesTable> {
  $$LocalProductAssembliesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessoryProductId => $composableBuilder(
    column: $table.accessoryProductId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalProductAssembliesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProductAssembliesTable> {
  $$LocalProductAssembliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get productVariantId => $composableBuilder(
    column: $table.productVariantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accessoryProductId => $composableBuilder(
    column: $table.accessoryProductId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$LocalProductAssembliesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalProductAssembliesTable,
          LocalProductAssembly,
          $$LocalProductAssembliesTableFilterComposer,
          $$LocalProductAssembliesTableOrderingComposer,
          $$LocalProductAssembliesTableAnnotationComposer,
          $$LocalProductAssembliesTableCreateCompanionBuilder,
          $$LocalProductAssembliesTableUpdateCompanionBuilder,
          (
            LocalProductAssembly,
            BaseReferences<
              _$AppDatabase,
              $LocalProductAssembliesTable,
              LocalProductAssembly
            >,
          ),
          LocalProductAssembly,
          PrefetchHooks Function()
        > {
  $$LocalProductAssembliesTableTableManager(
    _$AppDatabase db,
    $LocalProductAssembliesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProductAssembliesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalProductAssembliesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalProductAssembliesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> productVariantId = const Value.absent(),
                Value<String> accessoryProductId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProductAssembliesCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                productVariantId: productVariantId,
                accessoryProductId: accessoryProductId,
                quantity: quantity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String productVariantId,
                required String accessoryProductId,
                Value<double> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProductAssembliesCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                productVariantId: productVariantId,
                accessoryProductId: accessoryProductId,
                quantity: quantity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalProductAssembliesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalProductAssembliesTable,
      LocalProductAssembly,
      $$LocalProductAssembliesTableFilterComposer,
      $$LocalProductAssembliesTableOrderingComposer,
      $$LocalProductAssembliesTableAnnotationComposer,
      $$LocalProductAssembliesTableCreateCompanionBuilder,
      $$LocalProductAssembliesTableUpdateCompanionBuilder,
      (
        LocalProductAssembly,
        BaseReferences<
          _$AppDatabase,
          $LocalProductAssembliesTable,
          LocalProductAssembly
        >,
      ),
      LocalProductAssembly,
      PrefetchHooks Function()
    >;
typedef $$LocalProfilesTableCreateCompanionBuilder =
    LocalProfilesCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> fullName,
      Value<String> role,
      Value<String?> phone,
      Value<String?> shopName,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$LocalProfilesTableUpdateCompanionBuilder =
    LocalProfilesCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> fullName,
      Value<String> role,
      Value<String?> phone,
      Value<String?> shopName,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$LocalProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shopName => $composableBuilder(
    column: $table.shopName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shopName => $composableBuilder(
    column: $table.shopName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get shopName =>
      $composableBuilder(column: $table.shopName, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$LocalProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalProfilesTable,
          LocalProfile,
          $$LocalProfilesTableFilterComposer,
          $$LocalProfilesTableOrderingComposer,
          $$LocalProfilesTableAnnotationComposer,
          $$LocalProfilesTableCreateCompanionBuilder,
          $$LocalProfilesTableUpdateCompanionBuilder,
          (
            LocalProfile,
            BaseReferences<_$AppDatabase, $LocalProfilesTable, LocalProfile>,
          ),
          LocalProfile,
          PrefetchHooks Function()
        > {
  $$LocalProfilesTableTableManager(_$AppDatabase db, $LocalProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> shopName = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProfilesCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                fullName: fullName,
                role: role,
                phone: phone,
                shopName: shopName,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> shopName = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProfilesCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                fullName: fullName,
                role: role,
                phone: phone,
                shopName: shopName,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalProfilesTable,
      LocalProfile,
      $$LocalProfilesTableFilterComposer,
      $$LocalProfilesTableOrderingComposer,
      $$LocalProfilesTableAnnotationComposer,
      $$LocalProfilesTableCreateCompanionBuilder,
      $$LocalProfilesTableUpdateCompanionBuilder,
      (
        LocalProfile,
        BaseReferences<_$AppDatabase, $LocalProfilesTable, LocalProfile>,
      ),
      LocalProfile,
      PrefetchHooks Function()
    >;
typedef $$LocalPaymentsTableCreateCompanionBuilder =
    LocalPaymentsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String invoiceId,
      Value<String?> customerId,
      Value<double> amount,
      Value<String> paymentMethod,
      Value<String?> referenceNumber,
      Value<String?> notes,
      Value<String?> createdBy,
      Value<int> rowid,
    });
typedef $$LocalPaymentsTableUpdateCompanionBuilder =
    LocalPaymentsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> invoiceId,
      Value<String?> customerId,
      Value<double> amount,
      Value<String> paymentMethod,
      Value<String?> referenceNumber,
      Value<String?> notes,
      Value<String?> createdBy,
      Value<int> rowid,
    });

class $$LocalPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPaymentsTable> {
  $$LocalPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPaymentsTable> {
  $$LocalPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPaymentsTable> {
  $$LocalPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);
}

class $$LocalPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPaymentsTable,
          LocalPayment,
          $$LocalPaymentsTableFilterComposer,
          $$LocalPaymentsTableOrderingComposer,
          $$LocalPaymentsTableAnnotationComposer,
          $$LocalPaymentsTableCreateCompanionBuilder,
          $$LocalPaymentsTableUpdateCompanionBuilder,
          (
            LocalPayment,
            BaseReferences<_$AppDatabase, $LocalPaymentsTable, LocalPayment>,
          ),
          LocalPayment,
          PrefetchHooks Function()
        > {
  $$LocalPaymentsTableTableManager(_$AppDatabase db, $LocalPaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> invoiceId = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPaymentsCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                invoiceId: invoiceId,
                customerId: customerId,
                amount: amount,
                paymentMethod: paymentMethod,
                referenceNumber: referenceNumber,
                notes: notes,
                createdBy: createdBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String invoiceId,
                Value<String?> customerId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPaymentsCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                invoiceId: invoiceId,
                customerId: customerId,
                amount: amount,
                paymentMethod: paymentMethod,
                referenceNumber: referenceNumber,
                notes: notes,
                createdBy: createdBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPaymentsTable,
      LocalPayment,
      $$LocalPaymentsTableFilterComposer,
      $$LocalPaymentsTableOrderingComposer,
      $$LocalPaymentsTableAnnotationComposer,
      $$LocalPaymentsTableCreateCompanionBuilder,
      $$LocalPaymentsTableUpdateCompanionBuilder,
      (
        LocalPayment,
        BaseReferences<_$AppDatabase, $LocalPaymentsTable, LocalPayment>,
      ),
      LocalPayment,
      PrefetchHooks Function()
    >;
typedef $$LocalSystemLogsTableCreateCompanionBuilder =
    LocalSystemLogsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String level,
      required String message,
      Value<String?> error,
      Value<String?> stackTrace,
      Value<String?> context,
      Value<int> rowid,
    });
typedef $$LocalSystemLogsTableUpdateCompanionBuilder =
    LocalSystemLogsCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> level,
      Value<String> message,
      Value<String?> error,
      Value<String?> stackTrace,
      Value<String?> context,
      Value<int> rowid,
    });

class $$LocalSystemLogsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSystemLogsTable> {
  $$LocalSystemLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSystemLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSystemLogsTable> {
  $$LocalSystemLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSystemLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSystemLogsTable> {
  $$LocalSystemLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => column,
  );

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);
}

class $$LocalSystemLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSystemLogsTable,
          LocalSystemLog,
          $$LocalSystemLogsTableFilterComposer,
          $$LocalSystemLogsTableOrderingComposer,
          $$LocalSystemLogsTableAnnotationComposer,
          $$LocalSystemLogsTableCreateCompanionBuilder,
          $$LocalSystemLogsTableUpdateCompanionBuilder,
          (
            LocalSystemLog,
            BaseReferences<
              _$AppDatabase,
              $LocalSystemLogsTable,
              LocalSystemLog
            >,
          ),
          LocalSystemLog,
          PrefetchHooks Function()
        > {
  $$LocalSystemLogsTableTableManager(
    _$AppDatabase db,
    $LocalSystemLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSystemLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSystemLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSystemLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<String?> stackTrace = const Value.absent(),
                Value<String?> context = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSystemLogsCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                level: level,
                message: message,
                error: error,
                stackTrace: stackTrace,
                context: context,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String level,
                required String message,
                Value<String?> error = const Value.absent(),
                Value<String?> stackTrace = const Value.absent(),
                Value<String?> context = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSystemLogsCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                level: level,
                message: message,
                error: error,
                stackTrace: stackTrace,
                context: context,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSystemLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSystemLogsTable,
      LocalSystemLog,
      $$LocalSystemLogsTableFilterComposer,
      $$LocalSystemLogsTableOrderingComposer,
      $$LocalSystemLogsTableAnnotationComposer,
      $$LocalSystemLogsTableCreateCompanionBuilder,
      $$LocalSystemLogsTableUpdateCompanionBuilder,
      (
        LocalSystemLog,
        BaseReferences<_$AppDatabase, $LocalSystemLogsTable, LocalSystemLog>,
      ),
      LocalSystemLog,
      PrefetchHooks Function()
    >;
typedef $$LocalPricingRulesTableCreateCompanionBuilder =
    LocalPricingRulesCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String category,
      Value<String?> subcategory,
      Value<String?> material,
      Value<String?> variantType,
      Value<String?> dimensionSpec,
      Value<double> costPrice,
      Value<double> sellingPrice,
      Value<double> technicianPrice,
      Value<double> minSellingPrice,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$LocalPricingRulesTableUpdateCompanionBuilder =
    LocalPricingRulesCompanion Function({
      Value<String> id,
      Value<String> syncStatus,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> category,
      Value<String?> subcategory,
      Value<String?> material,
      Value<String?> variantType,
      Value<String?> dimensionSpec,
      Value<double> costPrice,
      Value<double> sellingPrice,
      Value<double> technicianPrice,
      Value<double> minSellingPrice,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$LocalPricingRulesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPricingRulesTable> {
  $$LocalPricingRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variantType => $composableBuilder(
    column: $table.variantType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dimensionSpec => $composableBuilder(
    column: $table.dimensionSpec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get technicianPrice => $composableBuilder(
    column: $table.technicianPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minSellingPrice => $composableBuilder(
    column: $table.minSellingPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPricingRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPricingRulesTable> {
  $$LocalPricingRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variantType => $composableBuilder(
    column: $table.variantType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dimensionSpec => $composableBuilder(
    column: $table.dimensionSpec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get technicianPrice => $composableBuilder(
    column: $table.technicianPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minSellingPrice => $composableBuilder(
    column: $table.minSellingPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPricingRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPricingRulesTable> {
  $$LocalPricingRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get material =>
      $composableBuilder(column: $table.material, builder: (column) => column);

  GeneratedColumn<String> get variantType => $composableBuilder(
    column: $table.variantType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dimensionSpec => $composableBuilder(
    column: $table.dimensionSpec,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);

  GeneratedColumn<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get technicianPrice => $composableBuilder(
    column: $table.technicianPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minSellingPrice => $composableBuilder(
    column: $table.minSellingPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$LocalPricingRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPricingRulesTable,
          LocalPricingRule,
          $$LocalPricingRulesTableFilterComposer,
          $$LocalPricingRulesTableOrderingComposer,
          $$LocalPricingRulesTableAnnotationComposer,
          $$LocalPricingRulesTableCreateCompanionBuilder,
          $$LocalPricingRulesTableUpdateCompanionBuilder,
          (
            LocalPricingRule,
            BaseReferences<
              _$AppDatabase,
              $LocalPricingRulesTable,
              LocalPricingRule
            >,
          ),
          LocalPricingRule,
          PrefetchHooks Function()
        > {
  $$LocalPricingRulesTableTableManager(
    _$AppDatabase db,
    $LocalPricingRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPricingRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPricingRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPricingRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> subcategory = const Value.absent(),
                Value<String?> material = const Value.absent(),
                Value<String?> variantType = const Value.absent(),
                Value<String?> dimensionSpec = const Value.absent(),
                Value<double> costPrice = const Value.absent(),
                Value<double> sellingPrice = const Value.absent(),
                Value<double> technicianPrice = const Value.absent(),
                Value<double> minSellingPrice = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPricingRulesCompanion(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                category: category,
                subcategory: subcategory,
                material: material,
                variantType: variantType,
                dimensionSpec: dimensionSpec,
                costPrice: costPrice,
                sellingPrice: sellingPrice,
                technicianPrice: technicianPrice,
                minSellingPrice: minSellingPrice,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String category,
                Value<String?> subcategory = const Value.absent(),
                Value<String?> material = const Value.absent(),
                Value<String?> variantType = const Value.absent(),
                Value<String?> dimensionSpec = const Value.absent(),
                Value<double> costPrice = const Value.absent(),
                Value<double> sellingPrice = const Value.absent(),
                Value<double> technicianPrice = const Value.absent(),
                Value<double> minSellingPrice = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPricingRulesCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                category: category,
                subcategory: subcategory,
                material: material,
                variantType: variantType,
                dimensionSpec: dimensionSpec,
                costPrice: costPrice,
                sellingPrice: sellingPrice,
                technicianPrice: technicianPrice,
                minSellingPrice: minSellingPrice,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPricingRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPricingRulesTable,
      LocalPricingRule,
      $$LocalPricingRulesTableFilterComposer,
      $$LocalPricingRulesTableOrderingComposer,
      $$LocalPricingRulesTableAnnotationComposer,
      $$LocalPricingRulesTableCreateCompanionBuilder,
      $$LocalPricingRulesTableUpdateCompanionBuilder,
      (
        LocalPricingRule,
        BaseReferences<
          _$AppDatabase,
          $LocalPricingRulesTable,
          LocalPricingRule
        >,
      ),
      LocalPricingRule,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalProjectsTableTableManager get localProjects =>
      $$LocalProjectsTableTableManager(_db, _db.localProjects);
  $$LocalMeasurementSessionsTableTableManager get localMeasurementSessions =>
      $$LocalMeasurementSessionsTableTableManager(
        _db,
        _db.localMeasurementSessions,
      );
  $$LocalRoomsTableTableManager get localRooms =>
      $$LocalRoomsTableTableManager(_db, _db.localRooms);
  $$LocalWallsTableTableManager get localWalls =>
      $$LocalWallsTableTableManager(_db, _db.localWalls);
  $$LocalWallOpeningsTableTableManager get localWallOpenings =>
      $$LocalWallOpeningsTableTableManager(_db, _db.localWallOpenings);
  $$LocalProductsTableTableManager get localProducts =>
      $$LocalProductsTableTableManager(_db, _db.localProducts);
  $$LocalProductVariantsTableTableManager get localProductVariants =>
      $$LocalProductVariantsTableTableManager(_db, _db.localProductVariants);
  $$LocalSupplierPricingsTableTableManager get localSupplierPricings =>
      $$LocalSupplierPricingsTableTableManager(_db, _db.localSupplierPricings);
  $$LocalInventoryItemsTableTableManager get localInventoryItems =>
      $$LocalInventoryItemsTableTableManager(_db, _db.localInventoryItems);
  $$LocalInventoryMovementsTableTableManager get localInventoryMovements =>
      $$LocalInventoryMovementsTableTableManager(
        _db,
        _db.localInventoryMovements,
      );
  $$LocalQuotesTableTableManager get localQuotes =>
      $$LocalQuotesTableTableManager(_db, _db.localQuotes);
  $$LocalQuoteItemsTableTableManager get localQuoteItems =>
      $$LocalQuoteItemsTableTableManager(_db, _db.localQuoteItems);
  $$LocalInvoicesTableTableManager get localInvoices =>
      $$LocalInvoicesTableTableManager(_db, _db.localInvoices);
  $$LocalInvoiceItemsTableTableManager get localInvoiceItems =>
      $$LocalInvoiceItemsTableTableManager(_db, _db.localInvoiceItems);
  $$LocalCustomersTableTableManager get localCustomers =>
      $$LocalCustomersTableTableManager(_db, _db.localCustomers);
  $$LocalProductPresetsTableTableManager get localProductPresets =>
      $$LocalProductPresetsTableTableManager(_db, _db.localProductPresets);
  $$LocalProductAssembliesTableTableManager get localProductAssemblies =>
      $$LocalProductAssembliesTableTableManager(
        _db,
        _db.localProductAssemblies,
      );
  $$LocalProfilesTableTableManager get localProfiles =>
      $$LocalProfilesTableTableManager(_db, _db.localProfiles);
  $$LocalPaymentsTableTableManager get localPayments =>
      $$LocalPaymentsTableTableManager(_db, _db.localPayments);
  $$LocalSystemLogsTableTableManager get localSystemLogs =>
      $$LocalSystemLogsTableTableManager(_db, _db.localSystemLogs);
  $$LocalPricingRulesTableTableManager get localPricingRules =>
      $$LocalPricingRulesTableTableManager(_db, _db.localPricingRules);
}
