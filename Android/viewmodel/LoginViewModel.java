package com.zoundz.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.android.volley.error.VolleyError;
import com.google.gson.Gson;
import com.kmgrv.networklib.handler.DataHandlerCallback;
import com.kmgrv.networklib.util.ErrorHelper;
import com.zoundz.application.AppController;
import com.zoundz.bean.UserBean;
import com.zoundz.util.Config;

import org.json.JSONObject;

import java.util.HashMap;
/*
 * Copyright Subcodevs, Inc. 2021
 */
public class LoginViewModel extends ZoundzViewModel implements DataHandlerCallback {

    private MutableLiveData<Boolean> isLoggedin;
    private MutableLiveData<UserBean> userBean;

    public LoginViewModel() {
        isLoggedin = new MutableLiveData<>();
        userBean = new MutableLiveData<>();
        setDataHandlerCallback();

    }

    public void setDataHandlerCallback(){
        AppController.getInstance().getRepository().setDataHandlerCallback(this);
    }


    public LiveData<Boolean> getIsLoggedin() {
        return isLoggedin;
    }

    public LiveData<UserBean> getUserBean() {
        return userBean;
    }



    public void validate(String email, String accountType) {

        if (email.isEmpty()) {
            getErrorMsg().setValue("Email address is required");
        } else {
            getLoader().setValue(true);
            JSONObject params = AppController.getInstance().getCustomJsonParams().loginParams(email, accountType);
            String url = Config.BASE_URL + Config.LOGIN;

            AppController.getInstance().getRepository().postRequestOnNetwork(url, params, Config.POST_JSON_RESPONSE);

        }
    }


    @Override
    public void onSuccess(HashMap<String, Object> map) {
        getLoader().setValue(false);
        JSONObject obj = (JSONObject) map.get(Config.POST_JSON_RESPONSE);
        if (obj != null) {
            Gson gson = new Gson();
            UserBean data = null;

            data = gson.fromJson(obj.toString(), UserBean.class);

            userBean.setValue(data);

            isLoggedin.setValue(true);

        }
    }

    @Override
    public void onFailure(HashMap<String, Object> map) {
        super.onFailure(map);
    }
}
