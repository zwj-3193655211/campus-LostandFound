package com.campus.lostfound.modules.match.service;

import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.system.entity.User;

public interface DocumentOwnerMatchService {

    void notifyPotentialOwnerForItem(Item item);

    void notifyPotentialOwnerForVerifiedUser(User user);
}
