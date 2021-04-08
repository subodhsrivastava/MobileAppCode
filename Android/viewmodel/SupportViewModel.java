package com.zoundz.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.google.gson.Gson;
import com.kmgrv.networklib.handler.DataHandlerCallback;
import com.zoundz.application.AppController;
import com.zoundz.bean.UserBean;
import com.zoundz.util.Config;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;

/*
 * Copyright Subcodevs, Inc. 2021
 */
public class SupportViewModel extends ZoundzViewModel implements DataHandlerCallback {

    private MutableLiveData<Boolean> isSubmitted;
    private MutableLiveData<String> errorMsg;

    public SupportViewModel() {
        isSubmitted = new MutableLiveData<>();
        errorMsg = new MutableLiveData<>();
        setDataHandlerCallback();

    }

    public void setDataHandlerCallback(){
        AppController.getInstance().getRepository().setDataHandlerCallback(this);
    }


    public MutableLiveData<Boolean> getIsSubmitted() {
        return isSubmitted;
    }

    @Override
    public MutableLiveData<String> getErrorMsg() {
        return errorMsg;
    }

    public void validate(String subject, String feedback, String userId) {

        if (subject.isEmpty()) {
            getErrorMsg().setValue("Subject is required");
        }else if (feedback.isEmpty()) {
            getErrorMsg().setValue("Feedback is required");
        }  else {
            getLoader().setValue(true);
            JSONObject params = AppController.getInstance().getCustomJsonParams().supportParams(subject,feedback, userId);
            String url = Config.BASE_URL + Config.SUPPORT;

            AppController.getInstance().getRepository().postRequestOnNetwork(url, params, Config.POST_JSON_RESPONSE);

        }
    }


    @Override
    public void onSuccess(HashMap<String, Object> map) {
        getLoader().setValue(false);
        JSONObject obj = (JSONObject) map.get(Config.POST_JSON_RESPONSE);
        if (obj != null) {

            isSubmitted.setValue(true);
            try {
                getErrorMsg().setValue(obj.getString("msg"));
                String msg = obj.getString("message");
                errorMsg.setValue(msg);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public void onFailure(HashMap<String, Object> map) {
        super.onFailure(map);
    }
}
