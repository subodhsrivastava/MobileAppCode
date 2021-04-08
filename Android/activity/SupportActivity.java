package com.zoundz.activity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProviders;

import com.zoundz.R;
import com.zoundz.application.AppController;
import com.zoundz.bean.UserBean;
import com.zoundz.databinding.ActivityLoginBinding;
import com.zoundz.databinding.ActivitySupportBinding;
import com.zoundz.pref.UserPref;
import com.zoundz.receiver.ConnectivityReceiver;
import com.zoundz.util.CustomCrouton;
import com.zoundz.util.HeaderConfig;
import com.zoundz.viewmodel.LoginViewModel;
import com.zoundz.viewmodel.SupportViewModel;

/*
 * Copyright Subcodevs, Inc. 2021
 */

public class SupportActivity extends AppCompatActivity implements ConnectivityReceiver.ConnectivityReceiverListener, View.OnClickListener{

    private ActivitySupportBinding binding;
    private SupportViewModel viewModel;
    private UserBean userBean;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivitySupportBinding.inflate(getLayoutInflater());
        View view = binding.getRoot();
        setContentView(view);

        viewModel = ViewModelProviders.of(this).get(SupportViewModel.class);
        userBean = UserPref.getUser();

        binding.requestSupport.setOnClickListener(this);

        observeValidation();
        observeLoader();
        observeSuccessLogin();
    }

    private void observeLoader() {
        viewModel.getLoader().observe(this, new Observer<Boolean>() {
            @Override
            public void onChanged(@Nullable Boolean loader) {
                if(loader){
                    AppController.getInstance().getDefaultLoader().showProgress(SupportActivity.this);
                }else{
                    AppController.getInstance().getDefaultLoader().dismiss();
                }
            }
        });
    }

    private void observeValidation() {
        viewModel.getErrorMsg().observe(this, new Observer<String>() {
            @Override
            public void onChanged(@Nullable String s) {
                AppController.getInstance().getDefaultDialog().showError(SupportActivity.this,s);
            }
        });
    }

    private void observeSuccessLogin() {
        viewModel.getIsSubmitted().observe(this, new Observer<Boolean>() {
            @Override
            public void onChanged(@Nullable Boolean isSubmitted) {
                if(isSubmitted) {
                    AppController.getInstance().getDefaultDialog().showError(SupportActivity.this,"Submitted Successfully.");
                }
            }
        });
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {

            case R.id.back:
                finish();
                break;

            case R.id.requestSupport:
                viewModel.validate(binding.editSubject.getText().toString(), binding.editFeedback.getText().toString()  , userBean.getUserID() );
                break;

        }

    }

    @Override
    protected void onResume() {
        super.onResume();
        HeaderConfig.getInstance().configureHeader(binding.header, this,
                "Support");
        AppController.getInstance().setConnectivityListener(this);

        userBean = UserPref.getUser();
        if(viewModel!=null){
            viewModel.setDataHandlerCallback();
        }

    }

    @Override
    public void onNetworkConnectionChanged(boolean isConnected) {
        if (!isConnected) {
            new CustomCrouton(this, getString(R.string.no_connection), binding.errorCheckLayout.errorCheckLayout).setInAnimation();
        }
    }
}
