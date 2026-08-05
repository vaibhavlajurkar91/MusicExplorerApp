// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_model.dart';



class SongModelAdapter extends TypeAdapter<SongModel> {
  @override
  final int typeId = 0;

  @override
  SongModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongModel(
      trackId: fields[0] as int,
      trackName: fields[1] as String,
      artistName: fields[2] as String,
      collectionName: fields[3] as String,
      artworkUrl100: fields[4] as String,
      previewUrl: fields[5] as String?,
      trackTimeMillis: fields[6] as int?,
      primaryGenreName: fields[7] as String?,
      releaseDate: fields[8] as DateTime?,
      artistId: fields[9] as int?,
      collectionId: fields[10] as int?,
      trackNumber: fields[11] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SongModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.trackId)
      ..writeByte(1)
      ..write(obj.trackName)
      ..writeByte(2)
      ..write(obj.artistName)
      ..writeByte(3)
      ..write(obj.collectionName)
      ..writeByte(4)
      ..write(obj.artworkUrl100)
      ..writeByte(5)
      ..write(obj.previewUrl)
      ..writeByte(6)
      ..write(obj.trackTimeMillis)
      ..writeByte(7)
      ..write(obj.primaryGenreName)
      ..writeByte(8)
      ..write(obj.releaseDate)
      ..writeByte(9)
      ..write(obj.artistId)
      ..writeByte(10)
      ..write(obj.collectionId)
      ..writeByte(11)
      ..write(obj.trackNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
