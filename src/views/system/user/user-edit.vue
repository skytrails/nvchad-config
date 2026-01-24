<!-- 修正后的模板 -->
<template>
  <el-dialog width="720px" :visible="visible" :lock-scroll="false" :destroy-on-close="true"
    custom-class="ele-dialog-form user-edit-dialog" :title="isUpdate ? '修改用户' : '添加用户'" @update:visible="updateVisible">
    <div class="dialog-content">
      <el-form ref="form" :model="form" :rules="rules" label-width="90px" label-position="left">
        <el-row :gutter="24">
          <el-col :sm="12">
            <!-- 登录账号 -->
            <el-form-item label="登录账号:" prop="username" class="form-item-enhanced">
              <div class="input-wrapper">
                <el-input clearable :maxlength="20" :disabled="isUpdate" v-model="form.username" placeholder="请输入用户账号"
                  :prefix-icon="isUpdate ? 'el-icon-lock' : 'el-icon-user'" size="medium" />
                <div v-if="!isUpdate" class="input-tips">登录后不可修改</div>
              </div>
            </el-form-item>

            <!-- 用户名 -->
            <el-form-item label="用户名:" prop="realname" class="form-item-enhanced">
              <el-input clearable :maxlength="20" v-model="form.realname" placeholder="请输入用户姓名"
                prefix-icon="el-icon-user" size="medium" />
            </el-form-item>

            <!-- 邮箱 -->
            <el-form-item label="邮箱:" prop="email" class="form-item-enhanced">
              <el-input clearable :maxlength="100" v-model="form.email" placeholder="请输入邮箱地址"
                prefix-icon="el-icon-message" size="medium">
                <!-- 修正插槽语法 -->
                <template v-if="form.email && validate.email.test(form.email)" #append>
                  <i class="el-icon-check email-check" />
                </template>
              </el-input>
            </el-form-item>

            <!-- 状态 -->
            <el-form-item label="状态:" prop="status" class="form-item-enhanced">
              <el-radio-group v-model="form.status">
                <el-radio :label="1" class="status-radio">
                  <span class="status-dot status-active"></span>
                  在用
                </el-radio>
                <el-radio :label="2" class="status-radio">
                  <span class="status-dot status-disabled"></span>
                  禁用
                </el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>

          <el-col :sm="12">
            <!-- 登录密码 -->
            <el-form-item label="登录密码:" prop="password" class="form-item-enhanced">
              <div class="input-wrapper">
                <el-input show-password :disabled="isUpdate" :maxlength="20" v-model="form.password"
                  placeholder="请输入登录密码" prefix-icon="el-icon-lock" size="medium" />
                <div v-if="!isUpdate" class="input-tips">建议包含字母、数字和符号</div>
              </div>
            </el-form-item>

            <!-- 性别 -->
            <el-form-item label="性别:" prop="gender" class="form-item-enhanced">
              <el-select clearable class="ele-block" v-model="form.gender" placeholder="请选择性别" size="medium">
                <el-option label="男" :value="1">
                  <div class="gender-option">
                    <i class="el-icon-male male-icon"></i>
                    <span>男</span>
                  </div>
                </el-option>
                <el-option label="女" :value="2">
                  <div class="gender-option">
                    <i class="el-icon-female female-icon"></i>
                    <span>女</span>
                  </div>
                </el-option>
                <el-option label="保密" :value="3">
                  <div class="gender-option">
                    <i class="el-icon-question secret-icon"></i>
                    <span>保密</span>
                  </div>
                </el-option>
              </el-select>
            </el-form-item>

            <!-- 手机号 -->
            <el-form-item label="手机号:" prop="mobile" class="form-item-enhanced">
              <el-input clearable :maxlength="11" v-model="form.mobile" placeholder="请输入手机号码"
                prefix-icon="el-icon-phone" size="medium">
                <!-- 修正插槽语法 -->
                <template #prepend>
                  <div class="mobile-prefix">+86</div>
                </template>
              </el-input>
            </el-form-item>

            <!-- 创建日期 -->
            <el-form-item label="创建日期:" prop="birthday" class="form-item-enhanced">
              <el-date-picker type="date" disabled class="ele-fluid" v-model="form.birthday" value-format="yyyy-MM-dd"
                format="yyyy-MM-dd" placeholder="创建日期" prefix-icon="el-icon-date" size="medium" />
            </el-form-item>
          </el-col>
        </el-row>

        <!-- 角色 -->
        <el-form-item label="角色:" prop="roleIds" class="form-item-enhanced role-select">
          <el-select multiple clearable class="ele-block" v-model="form.roleIds" placeholder="请选择角色（可多选）" size="medium">
            <el-option v-for="item in roleList" :key="item.id" :value="item.id" :label="item.name" />
          </el-select>
          <div class="select-tips">已选择 {{ (form.roleIds && form.roleIds.length) || 0 }} 个角色</div>
        </el-form-item>

        <!-- 个人简介 -->
        <el-form-item label="个人简介:" class="form-item-enhanced">
          <div class="textarea-wrapper">
            <el-input :rows="4" clearable type="textarea" :maxlength="200" v-model="form.intro"
              placeholder="请输入个人简介（限200字）" resize="none" show-word-limit />
            <div class="textarea-icon">
              <i class="el-icon-edit"></i>
            </div>
          </div>
        </el-form-item>
      </el-form>
    </div>

    <!-- 修正插槽语法 -->
    <template #footer>
      <div class="dialog-footer">
        <el-button size="medium" @click="updateVisible(false)" class="cancel-btn">
          取消
        </el-button>
        <el-button type="primary" size="medium" :loading="loading" @click="save" class="save-btn">
          <i class="el-icon-check"></i>
          保存
        </el-button>
      </div>
    </template>
  </el-dialog>
</template>

<script>
// 使用本地验证规则
const localValidate = {
  email: /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/,
  phone: /^1[3-9]\d{9}$/
};

export default {
  name: "UserEdit",
  props: {
    visible: Boolean,
    data: Object,
  },
  data() {
    return {
      city: [],
      provinceCity: [],
      province: [],
      form: Object.assign({ status: 1 }, this.data),
      rules: {
        username: [
          {
            required: true,
            type: "string",
            trigger: "blur",
          },
        ],
        realname: [
          { required: false, message: "请输入用户姓名", trigger: "blur" },
        ],
        gender: [{ required: false, message: "请选择性别", trigger: "blur" }],
        status: [{ required: false, message: "请选择状态", trigger: "blur" }],
        roleIds: [{ required: true, message: "请选择角色", trigger: "blur" }],
        email: [
          {
            pattern: localValidate.email,
            message: "邮箱格式不正确",
            trigger: "blur",
          },
        ],
        mobile: [
          {
            pattern: localValidate.phone,
            message: "手机号格式不正确",
            trigger: "blur",
          },
        ],
      },
      loading: false,
      isUpdate: false,
      updDir: "user",
      roleList: [],
      levelList: [],
      positionList: [],
      deptList: [],
      validate: localValidate, // 暴露给模板使用
    };
  },
  watch: {
    data() {
      if (this.data) {
        this.form = Object.assign({}, this.data, {
          roleIds: this.data.roles?.map((d) => d.id) || [],
        });
        this.city = this.data.city || [];
        this.form.password = "";
        this.isUpdate = true;
      } else {
        this.form = { status: 1 };
        this.isUpdate = false;
        this.city = [];
      }
    },
  },
  mounted() {
    this.queryRoles();
  },
  methods: {
    save() {
      this.$refs["form"].validate((valid) => {
        if (valid) {
          this.loading = true;
          this.form = Object.assign({}, this.form, {
            city: this.city,
          });
          this.$http
            .post(this.isUpdate ? "/admin/update" : "/admin/create", this.form)
            .then((res) => {
              this.loading = false;
              console.log("-----data:", res.data)
              if (res.data.code === 200) {
                this.$message({
                  type: "success",
                  message: res.data.message,
                  duration: 2000
                });
                if (!this.isUpdate) {
                  this.form = {};
                }
                this.updateVisible(false);
                this.$emit("done");
              } else {
                this.$message.error(res.data.message);
              }
            })
            .catch((e) => {
              this.loading = false;
              this.$message.error(e.message);
            });
        }
      });
    },
    updateVisible(value) {
      this.$emit("update:visible", value);
    },
    queryRoles() {
      this.$http
        .get("/role/getList")
        .then((res) => {
          if (res.data.code === 200) {
            this.roleList = res.data.data;
          } else {
            this.$message.error(res.data.message);
          }
        })
        .catch((e) => {
          this.$message.error(e.message);
        });
    },
  },
};
</script>

<style scoped>
/* ... 样式保持不变 ... */
.dialog-content {
  padding: 10px 20px 0;
}

.form-item-enhanced {
  margin-bottom: 22px;
}

.form-item-enhanced :deep(.el-form-item__label) {
  color: #606266;
  font-weight: 500;
  font-size: 14px;
}

.input-wrapper {
  position: relative;
}

.input-tips {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
  line-height: 1.4;
}

.email-check {
  color: #67c23a;
  font-weight: bold;
}

.status-radio {
  margin-right: 20px;
}

.status-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  margin-right: 6px;
  vertical-align: middle;
}

.status-active {
  background-color: #67c23a;
  box-shadow: 0 0 6px rgba(103, 194, 58, 0.4);
}

.status-disabled {
  background-color: #f56c6c;
  box-shadow: 0 0 6px rgba(245, 108, 108, 0.4);
}

.gender-option {
  display: flex;
  align-items: center;
  gap: 8px;
}

.male-icon {
  color: #409eff;
}

.female-icon {
  color: #f56c6c;
}

.secret-icon {
  color: #909399;
}

.mobile-prefix {
  padding: 0 8px;
  color: #909399;
  font-size: 14px;
}

.role-select {
  margin-bottom: 24px;
}

.select-tips {
  font-size: 12px;
  color: #409eff;
  margin-top: 6px;
  font-weight: 500;
}

.textarea-wrapper {
  position: relative;
}

.textarea-icon {
  position: absolute;
  right: 12px;
  top: 8px;
  color: #c0c4cc;
  font-size: 16px;
  pointer-events: none;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 10px 20px 20px;
}

.cancel-btn {
  min-width: 80px;
  border-color: #dcdfe6;
  color: #606266;
}

.cancel-btn:hover {
  border-color: #c0c4cc;
  background-color: #f5f7fa;
}

.save-btn {
  min-width: 80px;
  background: linear-gradient(135deg, #409eff 0%, #337ecc 100%);
  border: none;
  box-shadow: 0 2px 6px rgba(64, 158, 255, 0.3);
}

.save-btn:hover {
  background: linear-gradient(135deg, #66b1ff 0%, #409eff 100%);
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.4);
}

.save-btn:active {
  transform: translateY(1px);
}

.save-btn i {
  margin-right: 4px;
}

@media (max-width: 768px) {
  .dialog-content {
    padding: 0;
  }

  .form-item-enhanced {
    margin-bottom: 18px;
  }

  .dialog-footer {
    padding: 10px 0 15px;
  }
}
</style>

<style>
.user-edit-dialog .el-dialog__header {
  padding: 20px 20px 15px;
  border-bottom: 1px solid #f0f0f0;
}

.user-edit-dialog .el-dialog__title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.user-edit-dialog .el-dialog__body {
  padding: 0;
}

.user-edit-dialog .el-dialog__footer {
  padding: 0;
}

.user-edit-dialog .el-input__inner,
.user-edit-dialog .el-textarea__inner {
  border-radius: 8px;
  transition: all 0.3s ease;
}

.user-edit-dialog .el-input__inner:focus,
.user-edit-dialog .el-textarea__inner:focus {
  border-color: #409eff;
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.1);
}

.user-edit-dialog .el-select-dropdown__item {
  padding: 10px 20px;
}
</style>
