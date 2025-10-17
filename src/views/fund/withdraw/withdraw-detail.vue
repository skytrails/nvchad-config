<!-- 文章编辑弹窗 -->
<template>
  <div>
    <el-drawer
      class="edit-table"
      :title="'提款详情'"
      :visible.sync="showDrawer"
      :direction="direction"
      :size="'50%'"
      :before-close="close"
    >
      <el-card shadow="never" style="padding: 30px">
        <div class="operate-container">
          <i class="el-icon-warning color-danger" style="margin-left: 20px"></i>
          <span class="color-danger">当前提款状态：{{ form.statusName }}</span>
          <div class="operate-button-container" v-show="form.status===1">
            <el-button size="mini" @click="showAuditDialog">审核提款</el-button>
          </div>
        </div>
        <div class="table-title">
          <span class="font-small">提款信息</span>
        </div>
        <div class="table-layout">
          <template v-if="form.projectType === 1">
            <el-row>
              <el-col :span="6" class="table-cell-title">申请时间</el-col>
              <el-col :span="6" class="table-cell-title">提款金额</el-col>
              <el-col :span="6" class="table-cell-title">资金用途</el-col>
              <el-col :span="6" class="table-cell-title">患者现状</el-col>
            </el-row>
            <el-row>
              <el-col :span="6" class="table-cell">{{ form.createdAt }}</el-col>
              <el-col :span="6" class="table-cell">{{ form.amount }}</el-col>
              <el-col :span="6" class="table-cell">{{ form.purpose }}</el-col>
              <el-col :span="6" class="table-cell">{{ form.patientStatus }}</el-col>
            </el-row>
            <el-row>
              <el-col :span="6" class="table-cell-title">收款人</el-col>
              <el-col :span="6" class="table-cell-title">关系</el-col>
              <el-col :span="6" class="table-cell-title">收款银行</el-col>
              <el-col :span="6" class="table-cell-title">收款帐户</el-col>
            </el-row>
            <el-row>
              <el-col :span="6" class="table-cell">{{ form.payeeName }}</el-col>
              <el-col :span="6" class="table-cell">{{ form.payeeRelation }}</el-col>
              <el-col :span="6" class="table-cell">{{ form.bankName }}</el-col>
              <el-col :span="6" class="table-cell">{{ form.bankAccount }}</el-col>
            </el-row>
            <template v-if="form.status === 2">
              <el-row>
                <el-col :span="6" class="table-cell-title">第几笔款</el-col>
                <el-col :span="6" class="table-cell-title">打款金额</el-col>
                <el-col :span="6" class="table-cell-title">打款时间</el-col>
                <el-col :span="6" class="table-cell-title"> -</el-col>
              </el-row>
              <el-row>
                <el-col :span="6" class="table-cell">{{ form.applyNum }}</el-col>
                <el-col :span="6" class="table-cell">{{ form.receiveAmount }}</el-col>
                <el-col :span="6" class="table-cell">{{ form.paymentAt }}</el-col>
                <el-col :span="6" class="table-cell"> -</el-col>
              </el-row>
            </template>
          </template>
          <template v-else>
            <el-row>
              <el-col :span="8" class="table-cell-title">申请时间</el-col>
              <el-col :span="8" class="table-cell-title">提款金额</el-col>
              <el-col :span="8" class="table-cell-title">资金用途</el-col>
            </el-row>
            <el-row>
              <el-col :span="8" class="table-cell">{{ form.createdAt }}</el-col>
              <el-col :span="8" class="table-cell">{{ form.amount }}</el-col>
              <el-col :span="8" class="table-cell">{{ form.purpose }}</el-col>
            </el-row>
            <el-row>
              <el-col :span="8" class="table-cell-title">收款名称</el-col>
              <el-col :span="8" class="table-cell-title">收款银行</el-col>
              <el-col :span="8" class="table-cell-title">收款帐户</el-col>
            </el-row>
            <el-row>
              <el-col :span="8" class="table-cell">{{ form.payeeName }}</el-col>
              <el-col :span="8" class="table-cell">{{ form.bankName }}</el-col>
              <el-col :span="8" class="table-cell">{{ form.bankAccount }}</el-col>
            </el-row>
            <template v-if="form.status === 2">
              <el-row>
                <el-col :span="8" class="table-cell-title">第几笔款</el-col>
                <el-col :span="8" class="table-cell-title">打款金额</el-col>
                <el-col :span="8" class="table-cell-title">打款时间</el-col>
              </el-row>
              <el-row>
                <el-col :span="8" class="table-cell">{{ form.applyNum }}</el-col>
                <el-col :span="8" class="table-cell">{{ form.receiveAmount }}</el-col>
                <el-col :span="8" class="table-cell">{{ form.paymentAt }}</el-col>
              </el-row>
            </template>
          </template>
        </div>
        <div class="table-title">
          <span class="font-small">提款说明</span>
        </div>
        <div class="table-content">
          {{ form.description }}
        </div>
        <div class="table-title">
          <span class="font-small">相关证明</span>
        </div>
        <div class="table-content table-images">
          <template v-if="form.purposeImagesList && form.purposeImagesList.length > 0">
            <el-image class="image-item" v-for="(item, index) in form.purposeImagesList" :key="index"
                      :src="item"></el-image>
          </template>
          <template v-else>
            <el-empty description="暂无记录"></el-empty>
          </template>
        </div>
      </el-card>
    </el-drawer>
    <!--审核弹窗-->
    <el-dialog title="审核打款"
               :visible.sync="auditFormVisible"
               width="40%">
      <el-form ref="auditForm" :model="auditForm" :rules="rules" label-width="100px">
        <el-form-item label="打款结果：" prop="status">
          <el-radio-group v-model="auditForm.status">
            <el-radio :label="2">通过</el-radio>
            <el-radio :label="3">不通过</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="打款金额：" prop="receiveAmount">
          <el-input v-model="auditForm.receiveAmount"></el-input>
        </el-form-item>
        <el-form-item label="拒绝原因：">
          <el-input v-model="auditForm.rejectReason" type="textarea" rows="3">
          </el-input>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="auditFormVisible = false">取 消</el-button>
        <el-button type="primary" @click="handleAudit">确 定</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import '@riophae/vue-treeselect/dist/vue-treeselect.css';

export default {
  name: 'CfProjectsWithdrawDetail',
  props: {
    // 弹窗是否打开
    visible: Boolean,
    // 修改回显的数据
    data: Object,
  },
  components: {},
  data() {
    return {
      showDrawer: this.visible,
      direction: 'rtl',
      // 表单数据
      form: Object.assign({}, this.data),
      // 表单验证规则
      rules: {
        receiveAmount: [
          {required: true, message: '请输入打款金额', trigger: 'blur'}
        ],
        status: [
          {required: true, message: '请选择审核状态', trigger: 'blur'}
        ],
        sort: [
          {required: true, message: '请输入排序号', trigger: 'blur'}
        ]
      },
      // 提交状态
      loading: false,
      // 是否是修改
      isUpdate: false,
      // 上传目录
      updDir: 'article',

      // 审核弹窗
      auditFormVisible: false,
      auditForm: {status: 0, receiveAmount: 0, rejectReason: ''},
    };
  },
  watch: {
    data() {
      if (this.data) {
        this.form = Object.assign({}, this.data);
        this.isUpdate = true;
      } else {
        this.form = {};
        this.isUpdate = false;
      }
    }
  },
  computed: {},
  mounted() {
    this.getInfo();
  },
  methods: {
    /* 获取文章详情 */
    getInfo() {
      if (this.data.id > 0) {
        this.$http.get('/cfProjectsWithdraw/info/' + this.data.id).then(res => {
          if (res.data.code === 200) {
            this.form = res.data.data;
            this.isUpdate = true;
          } else {
            this.$message.error(res.data.message);
          }
        }).catch(e => {
          this.$message.error(e.message);
        });
      }
    },
    /* 更新visible */
    updateVisible(value) {
      this.$emit('update:visible', value);
    },
    /* 关闭页面 */
    close(hide) {
      if (hide) {
        hide();
      }
      this.$emit("done");
    },
    showAuditDialog() {
      this.auditFormVisible = true;
      this.auditForm.id = this.form.id;
      this.auditForm.status = this.form.status;
    },
    handleAudit() {
      this.$confirm('是否要提交打款信息?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.$http.post('/cfProjectsWithdraw/audit', this.auditForm).then(res => {
          if (res.data.code === 200) {
            this.auditFormVisible = false;
            this.getInfo();
            this.$message({
              type: 'success',
              message: res.data.message
            });
          } else {
            this.$message.error(res.data.message);
          }
        }).catch(e => {
          this.$message.error(e.message);
        });
      });
    },
  }
}
</script>

<style scoped>
.operate-container {
  background: #F2F6FC;
  height: 80px;
  /*margin: -20px -20px 0;*/
  line-height: 80px;
  border: 1px solid #DCDFE6;
}

.operate-button-container {
  float: right;
  margin-right: 20px
}

.table-title {
  margin-top: 25px;
  font-weight: bold;
}

.table-layout {
  margin-top: 15px;
  border-left: 1px solid #DCDFE6;
  border-top: 1px solid #DCDFE6;
}

.table-content {
  margin-top: 15px;
}

.table-cell {
  height: 60px;
  line-height: 40px;
  border-right: 1px solid #DCDFE6;
  border-bottom: 1px solid #DCDFE6;
  padding: 10px;
  font-size: 14px;
  color: #606266;
  text-align: center;
  overflow: hidden;
}

.table-cell-title {
  height: 38px;
  border-right: 1px solid #DCDFE6;
  border-bottom: 1px solid #DCDFE6;
  padding: 10px;
  background: #F2F6FC;
  box-sizing: border-box;
  text-align: center;
  font-size: 14px;
  color: #303133;
}

.table-images {
  display: flex;
  flex-wrap: wrap;
}

.table-images .image-item {
  width: 160px;
  height: 160px;
  margin-right: 15px;
  margin-bottom: 15px;
}

.table-content >>> .el-empty {
  flex: 1;
  padding: 0;
}

.table-content >>> .el-empty__image {
  height: 120px;
}
</style>
