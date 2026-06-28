"""Typed native column-bucket schema.

The Python layer exposes a namedtuple whose 24 fields encode
``(positive|negative, bucket-type)`` coordinates.  Mojo represents those
coordinates explicitly, so callers cannot confuse a field name with a column
number or polarity.
"""

from std.collections import List, Set
from .universal import ColumnBucket


@fieldwise_init
struct ColumnBucketCoordinate(Copyable, Equatable, Writable):
    var name: String
    var polarity: Int
    var bucket_type: Int

    def __eq__(self, other: Self) -> Bool:
        return (
            self.name == other.name
            and self.polarity == other.polarity
            and self.bucket_type == other.bucket_type
        )

    def write_to[W: Writer](self, mut writer: W):
        writer.write(self.name, "=", "(", self.polarity, ", ", self.bucket_type, ")")


@fieldwise_init
struct ResolvedColumnBucket(Copyable):
    var valid: Bool
    var coordinate: ColumnBucketCoordinate


@fieldwise_init
struct ColumnSelectionBundle(Copyable):
    var coordinates: List[ColumnBucketCoordinate]

    def bucket_count(self) -> Int:
        return len(self.coordinates)

    def positive_bucket_count(self) -> Int:
        var count = 0
        for index in range(len(self.coordinates)):
            if self.coordinates[index].polarity == 0:
                count += 1
        return count

    def negative_bucket_count(self) -> Int:
        var count = 0
        for index in range(len(self.coordinates)):
            if self.coordinates[index].polarity == 1:
                count += 1
        return count

    def resolve(self, name: String) -> ResolvedColumnBucket:
        for index in range(len(self.coordinates)):
            if self.coordinates[index].name == name:
                return ResolvedColumnBucket(True, self.coordinates[index].copy())
        return ResolvedColumnBucket(False, ColumnBucketCoordinate("", -1, -1))

    def new_bucket_map(self) -> List[ColumnBucket]:
        var result = List[ColumnBucket]()
        for index in range(len(self.coordinates)):
            var coordinate = self.coordinates[index].copy()
            result.append(ColumnBucket(
                coordinate.polarity,
                coordinate.bucket_type,
                Set[Int](),
            ))
        return result^


def bootstrap_column_selection() -> ColumnSelectionBundle:
    var coordinates = List[ColumnBucketCoordinate]()
    coordinates.append(ColumnBucketCoordinate("ordinary", 0, 0))
    coordinates.append(ColumnBucketCoordinate("generated1", 0, 1))
    coordinates.append(ColumnBucketCoordinate("concat1", 0, 2))
    coordinates.append(ColumnBucketCoordinate("kombi1", 0, 3))
    coordinates.append(ColumnBucketCoordinate("boolAndTupleSet1", 0, 4))
    coordinates.append(ColumnBucketCoordinate("gebroUni1", 0, 5))
    coordinates.append(ColumnBucketCoordinate("gebrGal1", 0, 6))
    coordinates.append(ColumnBucketCoordinate("generated2", 0, 7))
    coordinates.append(ColumnBucketCoordinate("kombi2", 0, 8))
    coordinates.append(ColumnBucketCoordinate("gebrEmo1", 0, 9))
    coordinates.append(ColumnBucketCoordinate("gebrGroe1", 0, 10))
    coordinates.append(ColumnBucketCoordinate("metakonkret", 0, 11))
    coordinates.append(ColumnBucketCoordinate("ordinaryNot", 1, 0))
    coordinates.append(ColumnBucketCoordinate("generate1dNot", 1, 1))
    coordinates.append(ColumnBucketCoordinate("concat1Not", 1, 2))
    coordinates.append(ColumnBucketCoordinate("kombi1Not", 1, 3))
    coordinates.append(ColumnBucketCoordinate("boolAndTupleSet1Not", 1, 4))
    coordinates.append(ColumnBucketCoordinate("gebroUni1Not", 1, 5))
    coordinates.append(ColumnBucketCoordinate("gebrGal1Not", 1, 6))
    coordinates.append(ColumnBucketCoordinate("generated2Not", 1, 7))
    coordinates.append(ColumnBucketCoordinate("kombi2Not", 1, 8))
    coordinates.append(ColumnBucketCoordinate("gebrEmo1Not", 1, 9))
    coordinates.append(ColumnBucketCoordinate("gebrGroe1Not", 1, 10))
    coordinates.append(ColumnBucketCoordinate("metakonkretNot", 1, 11))
    return ColumnSelectionBundle(coordinates^)


def column_bucket_names(bundle: ColumnSelectionBundle) -> List[String]:
    var result = List[String]()
    for index in range(len(bundle.coordinates)):
        result.append(bundle.coordinates[index].name)
    return result^


def bucket_index_for_coordinate(
    buckets: List[ColumnBucket],
    coordinate: ColumnBucketCoordinate,
) -> Int:
    for index in range(len(buckets)):
        if (
            buckets[index].polarity == coordinate.polarity
            and buckets[index].bucket_type == coordinate.bucket_type
        ):
            return index
    return -1
