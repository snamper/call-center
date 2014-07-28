package com.redcard.telephone.dao;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.PagingAndSortingRepository;

import com.redcard.telephone.entity.TelephoneImportDetail;

public interface TelephoneImportDetailDao extends PagingAndSortingRepository<TelephoneImportDetail,String> {
	@Query("select count(m) from TelephoneImportDetail m where m.fldAssignStatus = ?1")
    public Long countByAssignStatus(Integer assignStatus);
}