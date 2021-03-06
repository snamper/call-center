package com.redcard.message.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.common.core.grid.GridPageRequest;
import com.common.core.util.GenericPageHQLQuery;
import com.redcard.message.dao.MessageTemplateDao;
import com.redcard.message.entity.MessageTemplate;

import java.util.List;

@Component
public class MessageTemplateManager extends GenericPageHQLQuery<MessageTemplate> {

    // private static Logger logger =
    // LoggerFactory.getLogger(MessageTemplateManager.class);

    @Autowired
    private MessageTemplateDao messageTemplateDao;

    @Transactional(readOnly = false)
    public void save(MessageTemplate messageTemplate) {
        messageTemplateDao.save(messageTemplate);
    }

    public MessageTemplate find(String fldId) {
        return messageTemplateDao.findOne(fldId);
    }

    public List<MessageTemplate> findAll() {
        return messageTemplateDao.findAll();
    }

    public boolean isExistMessageTemplate(MessageTemplate messageTemplate) {
        Long messageTemplateCount = messageTemplateDao.countByTemplateName(messageTemplate.getFldName());
        if (messageTemplateCount > 0) {
            return true;
        } else {
            return false;
        }
    }

    public Page<MessageTemplate> queryMessageTemplates(GridPageRequest page, String where) {
        return (Page<MessageTemplate>) super.findAll(where, page);
    }

}