--对表进行压缩 压缩率50%
ALTER TABLE CZ_TEST MOVE;

--索引失效，进行重建  online-重建不会影响正常的业务
ALTER INDEX idx_object_id_cz REBUILD ONLINE NOLOGGING PARALLEL 8;

--取消索引并行
ALTER INDEX idx_object_id_cz NOPARALLEL;

