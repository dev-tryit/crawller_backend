abstract class WithDocId {
  int? documentId;
  String? email;

  WithDocId();
  
  @override
  bool operator ==(dynamic other) => documentId == other.documentId;
}
