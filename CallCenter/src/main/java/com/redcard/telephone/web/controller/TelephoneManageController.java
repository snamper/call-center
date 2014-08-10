package com.redcard.telephone.web.controller;

import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.common.core.grid.AsyncResponse;
import com.common.core.grid.DataResponse;
import com.common.core.grid.GridPageRequest;
import com.common.core.util.FilterGroupUtil;
import com.redcard.telephone.entity.TelephoneAssignDetail;
import com.redcard.telephone.entity.TelephoneExchange;
import com.redcard.telephone.entity.TelephoneTask;
import com.redcard.telephone.service.TelephoneAssignDetailManager;
import com.redcard.telephone.service.TelephoneAssignManager;
import com.redcard.telephone.service.TelephoneExchangeManager;
import com.redcard.telephone.service.TelephoneTaskManager;

@Controller
@RequestMapping(value = "/telephone/manage")
public class TelephoneManageController {
	private static Logger log = LoggerFactory.getLogger(TelephoneManageController.class);
	
	@Autowired
	private TelephoneAssignDetailManager telephoneAssignDetailManager;
	@Autowired
	private TelephoneAssignManager telephoneAssignManager;
	@Autowired
	private TelephoneExchangeManager telephoneExchangeManager;
	@Autowired
	private TelephoneTaskManager telephoneTaskManager;
	
	@RequestMapping(value = "init")
    public String init(String menuNo, Model model) {
        model.addAttribute("menuNo", menuNo);
        return "telephone/manage/list";
    }
	
	@RequestMapping(value = "list")
    @ResponseBody
    public DataResponse<TelephoneAssignDetail> list(GridPageRequest pageRequest, String where) {
        pageRequest.setSort("fldOperateDate", "desc");
        return (new DataResponse<TelephoneAssignDetail>(telephoneAssignDetailManager.findDetail(pageRequest, where)));
    }
	
	@RequestMapping(value = "listTask")
    public String listTask(String menuNo, String id,Model model) {
        model.addAttribute("menuNo", menuNo);
        model.addAttribute("assignDetailId", id);
        return "telephone/manage/taskDetail";
    }
	
	@RequestMapping(value = "listTaskDetail")
    @ResponseBody
    public DataResponse<TelephoneTask> listTaskDetail(GridPageRequest pageRequest, String fldAssignDetailId) {
        String where = "{}";
        where = FilterGroupUtil.addRule(where, "fldAssignDetailId", fldAssignDetailId, "string", "equal");
        return (new DataResponse<TelephoneTask>(telephoneTaskManager.findAll(where, pageRequest)));
    }
	
	@RequestMapping(value = "exchange")
    public String exchange(String menuNo, Model model) {
        model.addAttribute("menuNo", menuNo);
        return "telephone/manage/exchange";
    }
	
	@RequestMapping(value = "getCount")
    @ResponseBody
    public AsyncResponse getCount(String fldCallUserNo) {
        AsyncResponse result = new AsyncResponse(false,"");
        TelephoneAssignDetail telephoneAssignDetail = telephoneAssignManager.getCount(fldCallUserNo);
        List<TelephoneAssignDetail> list = new ArrayList<TelephoneAssignDetail>();
        list.add(telephoneAssignDetail);
        result.setData(list);
        return result;
    }
	
	@RequestMapping(value = "saveExchange")
    @ResponseBody
    public AsyncResponse saveExchange(TelephoneExchange telephoneExchange) {
        AsyncResponse result = new AsyncResponse(false, "话务交接成功");
        telephoneExchangeManager.saveExchange(telephoneExchange);
        return result;
    }
	
	@RequestMapping(value = "recover")
    public String recover(String menuNo, Model model) {
        model.addAttribute("menuNo", menuNo);
        return "telephone/manage/recover";
    }
	
	@RequestMapping(value = "saveRecover")
    @ResponseBody
    public AsyncResponse saveRecover(TelephoneExchange telephoneExchange) {
        AsyncResponse result = new AsyncResponse(false, "话务回收成功");
        telephoneExchangeManager.saveRecover(telephoneExchange);
        return result;
    }
}