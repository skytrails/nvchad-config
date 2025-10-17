<!-- 文章编辑弹窗 -->
<template>
  <div>
    <el-drawer
      class="edit-table"
      :title="'提款历史'"
      :visible.sync="showDrawer"
      :direction="direction"
      :size="'50%'"
      :before-close="close"
    >
      <el-card shadow="never" style="padding: 30px">
        <el-steps direction="vertical">
          <template v-for="(item, index) in list">
            <el-step :title="`第${index + 1}次提款`" status="process" :key="index">
              <div class="step-container" slot="description">
                <div class="step-item">
                  <div class="item-label">申请时间</div>
                  <div class="item-value">{{ item.createdAt }}</div>
                </div>
                <div class="step-item">
                  <div class="item-label">提现金额</div>
                  <div class="item-value">{{ item.amount }}</div>
                </div>
                <div class="step-item">
                  <div class="item-label">资金用途</div>
                  <div class="item-value">{{ item.purpose }}{{ item.purpose }}{{ item.purpose }}</div>
                </div>
                <div class="step-item step-image" v-if="form.purposeImagesList && form.purposeImagesList.length > 0">
                    <el-image class="image-item" v-for="(item, index) in form.purposeImagesList" :key="index"
                              :src="item"></el-image>
                </div>
                <div class="step-item" v-if="item.projectType === 1">
                  <div class="item-label">患者现状</div>
                  <div class="item-value">{{ item.patientStatus }}</div>
                </div>
                <div class="step-item">
                  <div class="item-label">{{ item.projectType === 1 ? '收款人' : '收款名称' }}</div>
                  <div class="item-value">{{ item.payeeName }}</div>
                </div>
                <div class="step-item" v-if="item.projectType === 1">
                  <div class="item-label">关系</div>
                  <div class="item-value">{{ item.payeeRelation }}</div>
                </div>
                <div class="step-item">
                  <div class="item-label">收款帐户</div>
                  <div class="item-value">{{ item.bankAccount }} / {{ item.bankName }}</div>
                </div>
                <div class="step-item">
                  <div class="item-label">打款状态</div>
                  <div class="item-value">{{ item.statusName }}</div>
                </div>
                <div class="step-item">
                  <div class="item-label">打款时间</div>
                  <div class="item-value">{{ item.paymentAt }}</div>
                </div>
                <div class="step-item">
                  <div class="item-label">到账金额</div>
                  <div class="item-value">{{ item.receiveAmount }}</div>
                </div>
              </div>
            </el-step>
          </template>
<!--          <el-step title="步骤 2" status="process"></el-step>-->
        </el-steps>
      </el-card>
    </el-drawer>
  </div>
</template>

<script>
import '@riophae/vue-treeselect/dist/vue-treeselect.css';

export default {
  name: 'CfProjectsWithdrawHistory',
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
      rules: {},
      // 提交状态
      loading: false,
      // 是否是修改
      isUpdate: false,
      // 上传目录
      updDir: 'article',
      // 提款记录
      list: [],
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
        this.$http.get('/cfProjectsWithdraw/history/' + this.data.projectId).then(res => {
          if (res.data.code === 200) {
            this.list = res.data.data;
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
  }
}
</script>

<style scoped>
.step-container {
  padding-bottom: 20px;
}

.step-item {
  display: flex;
  font-size: 14px;
  line-height: 1.3;
  margin-top: 12px;
}

.step-item .item-label {
  width: 76px;
  position: relative;
  padding-right: 20px;
  box-sizing: border-box;
}

.step-item .item-label::after {
  content: '|';
  font-size: 15px;
  position: absolute;
  top: -2px;
  right: 8px;
}

.step-item .item-value {
  color: #888888;
  flex: 1;
}

.step-image {
  display: flex;
  flex-wrap: wrap;
}

.step-image .image-item {
  width: 130px;
  height: 130px;
  margin-right: 15px;
  margin-bottom: 15px;
}

.step-image >>> .el-empty {
  flex: 1;
  padding: 0;
}

.step-image >>> .el-empty__image {
  height: 100px;
}

</style>
